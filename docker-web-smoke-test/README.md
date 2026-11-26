# Docker Web Smoke Test

Builds a Docker image of a web app from your repository, starts it, waits until it answers over HTTP, then runs a check against it.
The container's logs are always printed at the end, so failures can be diagnosed.
This action does _not_ check out your repository; do that first.

For the check, either use a [bundled check](#app-kinds) for a common kind of app by setting `app-kind`, or [supply your own script](#your-own-check-script).

```yml
  - uses: actions/checkout@v4
  - uses: UoMResearchIT/actions/docker-web-smoke-test@main
    with:
      port: 8501
      app-kind: streamlit
```

If neither `app-kind` nor `check-script` is given, the action only checks that the app starts and answers on `ready-path`.

> [!NOTE]
> Linux runners only.
> GitHub-hosted Ubuntu runners have everything needed; self-hosted runners need Docker, `curl` and `python3`.

## App kinds

Every kind needs `port` and `app-kind`; the rest depends on the app.

| `app-kind` | For | `port` (usual) | Recommended `ready-path` | `check-env` settings |
| --- | --- | --- | --- | --- |
| [`fastapi`](#fastapi) | FastAPI APIs | 8000 | `/openapi.json` | `OPENAPI_PATH`, `DOCS_PATH`, `HEALTH_PATH` |
| [`flask`](#flask) | Flask apps, including behind Gunicorn | 5000 or 8000 | `/` (the default) | `EXPECT_TEXT`, `HEALTH_PATH`, `STATIC_PATH` |
| [`shiny`](#shiny) | R Shiny apps: `shiny::runApp()`, Shiny Server or shinylive | 3838 | the app's path, e.g. `/myapp/` for Shiny Server | `APP_PATH` (needed for Shiny Server) |
| [`static`](#static) | Static sites and single-page apps (React, Vite, etc.) served by nginx or similar | 80 | `/` (the default) | `APP_PATH`, `SPA_ROUTES` (needed for single-page apps) |
| [`streamlit`](#streamlit) | Streamlit apps | 8501 | `/_stcore/health` | _(none)_ |

Each kind can be tuned with settings passed through `check-env`, one `KEY=value` per line.
Every failure prints a `FAIL:` line saying what went wrong.

The unknown-path checks below request `/smoke-test/no-such-page`, and the repeated-request checks make ten requests, each on a new connection, so that they are spread across server workers.

### `fastapi`

For FastAPI apps, which serve an OpenAPI schema and docs page by default.

**Inputs:**

| Input | Value |
| --- | --- |
| `port` | **Required.** The port uvicorn listens on, usually `8000`. |
| `app-kind` | **Required.** `fastapi` |
| `ready-path` | Recommended: `/openapi.json`, as FastAPI apps often have no page at `/`. |
| `check-env` | Optional: the settings below. |

```yml
  - uses: UoMResearchIT/actions/docker-web-smoke-test@main
    with:
      port: 8000
      ready-path: /openapi.json
      app-kind: fastapi
      check-env: |
        HEALTH_PATH=/healthz
```

Checks that:

* the OpenAPI schema is valid JSON with an `openapi` field, ten times over;
* the docs page loads;
* `HEALTH_PATH`, if set, returns 200;
* an unknown path returns 404;
* the container has not logged a Python traceback.

**Settings** (through `check-env`):

| Setting | Default | Meaning |
| --- | --- | --- |
| `OPENAPI_PATH` | `/openapi.json` | Where the schema is. Set it empty to skip the schema check, e.g. if the app passes `openapi_url=None`. |
| `DOCS_PATH` | `/docs` | Where the docs page is. Set it empty to skip, e.g. if the app passes `docs_url=None`. |
| `HEALTH_PATH` | _(none)_ | A path that must return 200. |

### `flask`

For Flask apps, whether run with `flask run` or behind Gunicorn.

**Inputs:**

| Input | Value |
| --- | --- |
| `port` | **Required.** The port Flask or Gunicorn listens on, usually `5000` or `8000`. |
| `app-kind` | **Required.** `flask` |
| `ready-path` | Optional: the default `/` suits most apps. |
| `check-env` | Optional: the settings below. |

```yml
  - uses: UoMResearchIT/actions/docker-web-smoke-test@main
    with:
      port: 8000
      app-kind: flask
      check-env: |
        EXPECT_TEXT=Welcome
        HEALTH_PATH=/healthz
        STATIC_PATH=/static/style.css
```

Checks that:

* the home page (`/`) loads, and contains `EXPECT_TEXT` if set;
* `HEALTH_PATH` and `STATIC_PATH`, if set, return 200 (a failing static path usually means the static folder is missing from the image);
* an unknown path returns 404, not a 500 from a broken error handler;
* the home page returns 200 ten times over, which catches workers that keep their own state, such as an in-memory job queue;
* the container has not logged a Python traceback.

**Settings** (through `check-env`):

| Setting | Default | Meaning |
| --- | --- | --- |
| `EXPECT_TEXT` | _(none)_ | Text the home page must contain. |
| `HEALTH_PATH` | _(none)_ | A path that must return 200. |
| `STATIC_PATH` | _(none)_ | A static file that must return 200. |

The bundled script also has a commented-out example of submitting a form with a CSRF token (as used by Flask-WTF), for adapting in your [own copy](#your-own-check-script).

### `shiny`

For R Shiny apps.
They are usually served in one of three ways, and the check works out which from the page:

| Served by | Typical Dockerfile | What is checked |
| --- | --- | --- |
| `shiny::runApp()` | `CMD ["R", "-e", "shiny::runApp(port=3838, host='0.0.0.0')"]` | The page includes Shiny's JavaScript, every local script and stylesheet it links loads, and the websocket at `<app>/websocket/` accepts connections. |
| Shiny Server | `FROM rocker/shiny` | As above, with the websocket at `<app>/__sockjs__/websocket`. |
| shinylive | A static export served by a web server, as in [RSE-R-Shiny-Template](https://github.com/UoMResearchIT/RSE-R-Shiny-Template) | There is no R server or websocket, so instead: every local script and stylesheet loads, `app.json` (the bundled app) is valid JSON, and the `shinylive-sw.js` service worker is served from the app's own path. |

In all three cases the app's page must also return 200 ten times over.

**Inputs:**

| Input | Value |
| --- | --- |
| `port` | **Required.** The port the app listens on, usually `3838`. |
| `app-kind` | **Required.** `shiny` |
| `ready-path` | Recommended for Shiny Server: the app's folder, e.g. `/myapp/`, so the wait is for the app rather than the directory listing. Otherwise the default `/` is fine. |
| `check-env` | Required for Shiny Server: `APP_PATH` set to the app's folder. Otherwise optional. |

```yml
  - uses: UoMResearchIT/actions/docker-web-smoke-test@main
    with:
      port: 3838
      app-kind: shiny
```

Shiny Server's root page is a directory listing rather than an app, so point `APP_PATH` (and `ready-path`) at the app's folder:

```yml
  - uses: UoMResearchIT/actions/docker-web-smoke-test@main
    with:
      port: 3838
      ready-path: /myapp/
      app-kind: shiny
      check-env: |
        APP_PATH=/myapp/
```

**Settings** (through `check-env`):

| Setting | Default | Meaning |
| --- | --- | --- |
| `APP_PATH` | `/` | Where the app is served. |

The app's own output is drawn in the browser, so it cannot be checked with this action.
R errors are not detected either, as they only appear once a browser session runs the app's code.

### `static`

For static sites and single-page apps, such as a React or Vite build served by nginx.

**Inputs:**

| Input | Value |
| --- | --- |
| `port` | **Required.** The port the web server listens on, usually `80`. |
| `app-kind` | **Required.** `static` |
| `ready-path` | Optional: the default `/` suits most sites. |
| `check-env` | Required for single-page apps: `SPA_ROUTES=true`. Otherwise optional. |

```yml
  - uses: UoMResearchIT/actions/docker-web-smoke-test@main
    with:
      port: 80
      app-kind: static
      check-env: |
        SPA_ROUTES=true
```

Checks that:

* the page at `APP_PATH` loads and is HTML;
* every local script (`<script src>`) and stylesheet or preloaded module (`<link href>`) it links loads, which catches a wrong `base` path in the build. A file that comes back as an HTML page counts as missing, as a single-page app's fallback serves `index.html` in place of missing files;
* without `SPA_ROUTES`, an unknown path returns 404;
* with `SPA_ROUTES=true`, a deep link (`<app>/smoke-test/deep/link`) serves the app instead, which catches a missing `try_files $uri /index.html` fallback in nginx that would make reloading a deep link fail;
* the page returns 200 ten times over.

**Settings** (through `check-env`):

| Setting | Default | Meaning |
| --- | --- | --- |
| `APP_PATH` | `/` | Where the site is served. |
| `SPA_ROUTES` | _(unset)_ | Set to `true` for a single-page app with client-side routes. |

Links to other sites (`https://...`) are not checked.

### `streamlit`

For Streamlit apps.

**Inputs:**

| Input | Value |
| --- | --- |
| `port` | **Required.** The port Streamlit listens on, usually `8501`. |
| `app-kind` | **Required.** `streamlit` |
| `ready-path` | Recommended: `/_stcore/health`, which only answers once Streamlit is running. |
| `check-env` | Not used. |

```yml
  - uses: UoMResearchIT/actions/docker-web-smoke-test@main
    with:
      port: 8501
      ready-path: /_stcore/health
      app-kind: streamlit
```

Checks that:

* Streamlit's health endpoint (`/_stcore/health`) returns `ok`;
* the home page is Streamlit's page;
* the websocket the browser uses (`/_stcore/stream`) accepts connections, which catches proxy or `--server.baseUrlPath` mistakes;
* the container has not logged a Python traceback.

There are no settings.
The app's own content is drawn in the browser, so it cannot be checked with this action.

## Your own check script

Pass a script, relative to the repository root, as `check-script`:

```yml
  - uses: actions/checkout@v4
  - uses: UoMResearchIT/actions/docker-web-smoke-test@main
    with:
      port: 8000
      ready-path: /healthz
      check-script: scripts/smoke_check.sh
      check-env: |
        API_USER=smoke-test
```

The script is run with `bash` from the repository root, with these environment variables set:

* `BASE_URL`: where the app is, e.g. `http://127.0.0.1:8000`
* `CONTAINER_NAME`: the name of the running container, for `docker logs` or `docker exec`
* `APP_KIND`: the `app-kind` input, if given
* anything listed in `check-env`

A non-zero exit fails the job.

[`docker_smoke_check.sh`](docker_smoke_check.sh) (the bundled check) is a good starting point, with helpers for checking status codes, websockets and linked files.
It runs the function named `<app-kind>_check`, so to support another kind of app, copy it into your repository, add a function such as `dash_check`, and pass `check-script: scripts/docker_smoke_check.sh` with `app-kind: dash`.
If `APP_KIND` is unset or has no matching function, it fails and lists the kinds it has.

## Inputs

### Commonly Needed

* `port`

  Port the app listens on inside the container. It is published on the same host port. **Required.**

* `app-kind`

  Run the bundled check for this kind of app: `fastapi`, `flask`, `shiny`, `static` or `streamlit`. See [App kinds](#app-kinds). Also passed to `check-script` as `APP_KIND` if both are given. **Optional.**

* `check-script`

  Your own check script, relative to the repository root. Takes precedence over the bundled check. **Optional.**

* `check-env`

  Extra environment variables for the check, one `KEY=value` per line. Values may contain spaces. **Optional.**

* `ready-path`

  Path that must respond without an error (status below 400; redirects count) once the app is up. Defaults to `/`. **Optional.**

### Less Commonly Needed

* `context`

  Docker build context. Defaults to `.`. **Optional.**

* `dockerfile`

  Path to the Dockerfile. Defaults to `./Dockerfile`. **Optional.**

* `build-args`

  Build arguments, one `KEY=value` per line. **Optional.**

* `run-args`

  Extra arguments for `docker run`, such as `-e KEY=value`. Split on whitespace, so values cannot contain spaces. **Optional.**

* `ready-timeout`

  Seconds to wait for `ready-path` to respond. Defaults to `60`. **Optional.**

* `image-tag`

  Tag for the local image. Defaults to `docker-web-smoke:ci`. **Optional.**

* `cache-scope`

  GitHub Actions cache scope for build layers. Give each image its own scope if a repository builds more than one. Defaults to `buildkit`. **Optional.**

## Outputs

None.

## Permissions

The action itself needs no `GITHUB_TOKEN` permissions.
Checking out the repository first needs:

```yml
contents: read
```
