#!/usr/bin/env bash
# Copyright (c) 2026 The University of Manchester
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Bundled check for the docker-web-smoke-test and docker-compose-web-smoke-test
# actions. They run it when app-kind is set and no check-script is given, with
# these variables set:
#   BASE_URL        e.g. http://127.0.0.1:8000
#   CONTAINER_NAME  name or ID of the app's container
#   APP_KIND        the app-kind input
# plus anything passed through the check-env input. Optional settings:
#   INSECURE_TLS    true to accept self-signed HTTPS certificates (all)
#   APP_PATH        where the app is served, default / (shiny, static)
#   EXPECT_TEXT     text the home page must contain (flask)
#   HEALTH_PATH     path that must return HTTP 200, e.g. /healthz (flask, fastapi,
#                   django, wagtail)
#   ADMIN_PATH      admin login page, default /admin/login/ (django, wagtail)
#   STATIC_PATH     static file that must return HTTP 200 (flask)
#   OPENAPI_PATH    OpenAPI schema, default /openapi.json; empty skips (fastapi)
#   DOCS_PATH       API docs page, default /docs; empty skips (fastapi)
#   SPA_ROUTES      true if unknown paths should serve the app (static)
# A non-zero exit fails the job.
#
# APP_KIND=<name> runs the function <name>_check. To check another kind of
# app, copy this file into your repository, add a function such as
# dash_check, and pass your copy as check-script with app-kind: dash.
# You can also write a check script from scratch; the helpers below are a
# useful starting point.
#
# To try it locally:
#
#   APP_KIND=flask     BASE_URL=http://127.0.0.1:5000 ./docker_smoke_check.sh
#   APP_KIND=streamlit BASE_URL=http://127.0.0.1:8501 ./docker_smoke_check.sh

set -euo pipefail

base="${BASE_URL:?BASE_URL must be set}"

# APP_PATH with a trailing slash, so relative links resolve against it.
app_path="${APP_PATH:-/}"
app_path="${app_path%/}/"

# --- Reusable helpers -------------------------------------------------------

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

# Every request below goes through this, so that none can hang the job and
# INSECURE_TLS applies to all. A later --max-time in the arguments takes
# precedence.
curl() {
  if [ "${INSECURE_TLS:-}" = true ]; then
    command curl --max-time 30 --insecure "$@"
  else
    command curl --max-time 30 "$@"
  fi
}

# Print the HTTP status code for a GET request.
status_of() {
  curl --silent -o /dev/null -w '%{http_code}' "$@"
}

# Fail unless PATH returns HTTP status CODE (default 200).
expect_status() {
  local code
  code="$(status_of "$base$1")"
  [ "$code" = "${2:-200}" ] || fail "$1 returned HTTP $code, expected ${2:-200}"
}

# Unknown routes return 404 rather than a 500 from a broken error handler.
# Takes an optional path to try instead of the default.
expect_unknown_404() {
  expect_status "${1:-/smoke-test/no-such-page}" 404
}

# Fail unless PATH accepts a websocket upgrade. A reverse proxy or wrong base
# path usually breaks this while plain HTTP requests still work. curl holds
# the upgraded connection open until --max-time, so its exit code is ignored;
# the key is the sample 16-byte nonce from RFC 6455.
expect_websocket() {
  local code
  code="$(curl --silent -o /dev/null -w '%{http_code}' --max-time 3 \
    -H 'Connection: Upgrade' -H 'Upgrade: websocket' \
    -H 'Sec-WebSocket-Version: 13' -H 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' \
    "$base$1" || true)"
  [ "$code" = 101 ] || fail "websocket upgrade at $1 returned HTTP $code"
}

# Repeated requests on fresh connections all succeed. With several server
# workers this spreads requests across them, which catches per-worker state.
expect_repeatable() {
  local i code
  for i in $(seq 1 10); do
    code="$(status_of -H 'Connection: close' "$base$1")"
    [ "$code" = 200 ] || fail "request $i to $1 returned HTTP $code"
  done
}

# Pipes into grep use "grep >/dev/null" rather than "grep -q": grep -q stops
# reading at the first match, and with pipefail the writer's error would then
# make the whole pipeline fail.

# Print the scripts and stylesheets linked from the HTML on stdin, one URL per
# line: <script src>, and <link href> with rel stylesheet or modulepreload.
linked_assets() {
  python3 -c '
import sys
from html.parser import HTMLParser

class Links(HTMLParser):
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        rel = set((attrs.get("rel") or "").lower().split())
        if tag == "script" and attrs.get("src"):
            print(attrs["src"])
        elif tag == "link" and attrs.get("href") and rel & {"stylesheet", "modulepreload"}:
            print(attrs["href"])

Links().feed(sys.stdin.read())
'
}

# Fail unless every local script and stylesheet linked from the HTML on stdin
# loads. Links are resolved against app_path; external URLs are skipped. An
# HTML response counts as a failure, as a single-page app's fallback serves
# index.html with HTTP 200 for missing files.
expect_assets_load() {
  local link url result count=0
  while IFS= read -r link; do
    case "$link" in
      http://* | https://* | //* | data:*) continue ;;
      /*) url="$link" ;;
      *) url="$app_path${link#./}" ;;
    esac
    result="$(curl --silent -o /dev/null -w '%{http_code} %{content_type}' "$base$url")"
    case "$result" in
      "200 text/html"*) fail "$url returned an HTML page instead of the file (missing file behind a fallback?)" ;;
      "200 "*) ;;
      *) fail "$url returned HTTP ${result%% *}, expected 200" ;;
    esac
    count=$((count + 1))
  done < <(linked_assets)
  echo "Loaded $count linked assets"
}

# Fail if the container has logged a Python traceback so far.
check_logs_clean() {
  if [ -n "${CONTAINER_NAME:-}" ] \
    && docker logs "$CONTAINER_NAME" 2>&1 | grep 'Traceback (most recent call last)' >/dev/null; then
    fail "container logs contain a traceback"
  fi
}

# --- App checks: one <name>_check function per APP_KIND ---------------------

flask_check() {
  # The home page loads, and contains EXPECT_TEXT if given.
  page="$(curl --fail --silent "$base/")" || fail "home page did not return 2xx"
  if [ -n "${EXPECT_TEXT:-}" ]; then
    grep -qF -- "$EXPECT_TEXT" <<< "$page" \
      || fail "home page does not contain '$EXPECT_TEXT'"
  fi

  if [ -n "${HEALTH_PATH:-}" ]; then
    expect_status "$HEALTH_PATH"
  fi

  # A static file, which catches a static folder missing from the image.
  if [ -n "${STATIC_PATH:-}" ]; then
    expect_status "$STATIC_PATH"
  fi

  expect_unknown_404

  # A form POST with a CSRF token taken from the page. In your own copy,
  # uncomment and adapt this if the app uses Flask-WTF:
  #
  # jar="$(mktemp)"
  # trap 'rm -f "$jar"' EXIT
  # token="$(curl --fail --silent -c "$jar" -b "$jar" "$base/" \
  #   | sed -n 's/.*name="csrf_token" value="\([^"]*\)".*/\1/p' | head -n1)"
  # curl --fail --silent -c "$jar" -b "$jar" \
  #   -F "csrf_token=$token" -F 'name=smoke-test' "$base/submit" >/dev/null \
  #   || fail "form submission failed"

  expect_repeatable /
  check_logs_clean
}

fastapi_check() {
  # FastAPI serves its OpenAPI schema and docs page unless they are turned
  # off, in which case set OPENAPI_PATH= and DOCS_PATH= to skip them.
  openapi="${OPENAPI_PATH-/openapi.json}"
  docs="${DOCS_PATH-/docs}"

  if [ -n "$openapi" ]; then
    curl --fail --silent "$base$openapi" \
      | python3 -c 'import json,sys; assert "openapi" in json.load(sys.stdin)' \
      || fail "$openapi is not an OpenAPI schema"
    expect_repeatable "$openapi"
  fi
  if [ -n "$docs" ]; then
    expect_status "$docs"
  fi
  if [ -n "${HEALTH_PATH:-}" ]; then
    expect_status "$HEALTH_PATH"
  fi

  expect_unknown_404
  check_logs_clean
}

streamlit_check() {
  # Streamlit's built-in health endpoint.
  [ "$(curl --fail --silent "$base/_stcore/health")" = ok ] \
    || fail "/_stcore/health did not return ok"

  # The page shell is served. The app's own content is rendered in the browser
  # over a websocket, so it cannot be checked with curl.
  curl --fail --silent "$base/" | grep 'You need to enable JavaScript' >/dev/null \
    || fail "home page is not the Streamlit shell"

  expect_websocket /_stcore/stream
  check_logs_clean
}

# R Shiny, run any of three ways:
#   - shiny::runApp(), with the websocket at <app>/websocket/
#   - Shiny Server (e.g. rocker/shiny), with the websocket at <app>/__sockjs__/.
#     Its root is a directory listing, so set APP_PATH to the app, e.g. /myapp/
#   - shinylive, a static export that runs in the browser with no R server
shiny_check() {
  page="$(curl --fail --silent "$base$app_path")" \
    || fail "$app_path did not return 2xx"

  if grep -q 'shinylive' <<< "$page"; then
    echo "Detected a shinylive (static) export"
    expect_assets_load <<< "$page"
    curl --fail --silent "$base${app_path}app.json" \
      | python3 -c 'import json,sys; json.load(sys.stdin)' \
      || fail "${app_path}app.json is missing or not JSON"
    # The service worker has to be served from the app's own path.
    expect_status "${app_path}shinylive-sw.js"
    expect_repeatable "$app_path"
    return
  fi

  grep -q 'shiny.min.js' <<< "$page" \
    || fail "$app_path is not a Shiny app (no shiny.min.js); set APP_PATH if the app is not at /"
  expect_assets_load <<< "$page"

  if grep -q 'shiny-server-client' <<< "$page"; then
    echo "Detected Shiny Server"
    expect_websocket "${app_path}__sockjs__/websocket"
  else
    expect_websocket "${app_path}websocket/"
  fi

  expect_repeatable "$app_path"
}

# A static or single-page site, e.g. a React or Vite build served by nginx.
static_check() {
  page="$(curl --fail --silent "$base$app_path")" \
    || fail "$app_path did not return 2xx"
  grep -qi '<html' <<< "$page" || fail "$app_path is not an HTML page"
  expect_assets_load <<< "$page"

  # A single-page app must serve itself for its own routes (nginx try_files),
  # otherwise reloading a deep link gives a 404. Other sites should 404.
  if [ "${SPA_ROUTES:-}" = true ]; then
    curl --fail --silent "$base${app_path}smoke-test/deep/link" | grep -i '<html' >/dev/null \
      || fail "deep link did not serve the app; check the server falls back to index.html"
  else
    code="$(status_of "$base/smoke-test/no-such-page")"
    [ "$code" = 404 ] \
      || fail "unknown path returned HTTP $code, expected 404 (set SPA_ROUTES=true for a single-page app)"
  fi

  expect_repeatable "$app_path"
}

# Fetch the Django admin login page into $page, failing with a hint if it
# does not load. It needs the database, templates and static files manifest,
# so it covers most of a Django stack.
fetch_admin_page() {
  admin="${ADMIN_PATH:-/admin/login/}"
  local code
  code="$(status_of "$base$admin")"
  [ "$code" = 200 ] \
    || fail "$admin returned HTTP $code; check the logs (a missing migrate or collectstatic is a common cause)"
  page="$(curl --fail --silent "$base$admin")"
}

# Django, typically behind nginx with Postgres (see docker-compose-web-smoke-test).
# Run migrate and collectstatic first, or the admin page and its static files
# will fail.
django_check() {
  # The home page may legitimately be a 404 or a redirect on a fresh database,
  # but not a server error. A 400 means Django rejected the Host header.
  code="$(status_of "$base/")"
  case "$code" in
    2?? | 3?? | 401 | 403 | 404) ;;
    400) fail "/ returned HTTP 400; check ALLOWED_HOSTS includes the host in $base" ;;
    *) fail "/ returned HTTP $code; check the logs" ;;
  esac

  if [ -n "${HEALTH_PATH:-}" ]; then
    expect_status "$HEALTH_PATH"
  fi

  # The admin page's stylesheets and scripts are served from STATIC_ROOT,
  # usually by nginx, which catches static files not being served.
  fetch_admin_page
  grep -q csrfmiddlewaretoken <<< "$page" || fail "$admin has no login form"
  expect_assets_load <<< "$page"

  # APPEND_SLASH redirects paths without a trailing slash, so use one.
  expect_unknown_404 /smoke-test/no-such-page/
  expect_repeatable "$admin"
  check_logs_clean
}

# Wagtail is Django, with its own admin at /admin/ by default.
wagtail_check() {
  fetch_admin_page
  grep -qi wagtail <<< "$page" || fail "$admin is not the Wagtail admin login page"
  django_check
}

# --- Run the check named by APP_KIND ----------------------------------------

# Fail early with a hint if HTTPS uses a certificate curl does not trust
# (curl exit code 60), rather than as a confusing failure inside a check.
tls_rc=0
curl --silent -o /dev/null "$base/" || tls_rc=$?
if [ "$tls_rc" = 60 ]; then
  fail "$base has an untrusted certificate; set INSECURE_TLS=true if it is self-signed"
fi

available="$(declare -F | awk '$3 ~ /_check$/ { sub(/_check$/, "", $3); print $3 }' | paste -sd ' ' -)"
if [ -z "${APP_KIND:-}" ]; then
  fail "APP_KIND is not set (available: $available)"
fi
if ! declare -F "${APP_KIND}_check" >/dev/null; then
  fail "no check for APP_KIND=$APP_KIND (available: $available)"
fi
"${APP_KIND}_check"

echo "Smoke check passed"
