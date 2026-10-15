# Docker Compose Web Smoke Test

Builds and starts a web app's Docker Compose stack, runs any setup commands (such as database migrations), waits until it answers over HTTP, then runs a check against it.
Logs from every service are always printed at the end, and the stack and its volumes are removed.
This action does _not_ check out your repository; do that first.

Use this when the app needs several containers, such as Django with Postgres behind nginx.
For an app in a single container, use [`docker-web-smoke-test`](../docker-web-smoke-test) instead.
Both actions share the same [bundled checks](../docker-web-smoke-test#app-kinds) and support [your own check script](#your-own-check-script).

```yml
  - uses: actions/checkout@v4
  - uses: UoMResearchIT/actions/docker-compose-web-smoke-test@main
    with:
      base-url: http://localhost:8000
      app-kind: django
      app-service: web
      setup-commands: |
        web: python manage.py migrate --no-input
```

> [!NOTE]
> Linux runners only.
> GitHub-hosted Ubuntu runners have everything needed; self-hosted runners need Docker with Compose v2, `curl` and `python3`.

## What it does

1. Prepares `.env`: copies `env-template` to `.env`, then sets each of `env-values` in it.
2. Creates any file-based Compose secrets that are missing, with random values (turn off with `generate-secrets: false`).
3. Builds the images with `docker compose build`.
4. Starts the stack with `docker compose up -d`.
5. Runs each of `setup-commands` with `docker compose exec`, as in a manual deployment. A failing command is retried every 5 seconds, as the database may still be starting; each command, including its retries, is stopped if it takes longer than `setup-timeout`. Then each service that ran a command is restarted, so it picks up the results (Django reads the `collectstatic` manifest only at startup).
6. Waits until `base-url` + `ready-path` responds. It fails early if a service crashes, i.e. is restarting or has exited with an error; one-off services that exit cleanly are fine.
7. Runs the check chosen with `app-kind`, or your `check-script`.
8. Always prints every service's logs, then runs `docker compose down --volumes --rmi local`, removing the stack, its volumes and the images it built.

Image layers are not cached between runs, so every run builds the stack from scratch.

Each run uses its own Compose project name, so that jobs sharing a Docker daemon, as on a self-hosted runner, get separate stacks and cannot remove each other's.

> [!WARNING]
> That separation does not cover containers, networks or volumes given fixed names in the Compose file (`container_name:` or `name:`), as WADS sites do.
> Step 8 deletes the stack's volumes, including any with fixed names.
> On a self-hosted runner, make sure the smoke test cannot use the same names as a real deployment or another job running at the same time, e.g. by giving each its own `WADS_CONTAINER_PREFIX`.

## Wagtail And Django Stack (WADS) sites

These inputs work with sites built from [Wagtail-And-Django-Stack](https://github.com/UoMResearchIT/Wagtail-And-Django-Stack), which run Django, Postgres and nginx, with the production settings used by default:

```yml
  - uses: actions/checkout@v4
  - uses: UoMResearchIT/actions/docker-compose-web-smoke-test@main
    with:
      base-url: https://localhost
      insecure-tls: true
      ready-path: /healthz/
      app-kind: wagtail
      app-service: django
      env-template: .env.dist.template
      env-values: |
        DJANGO_USER=${RUNNER_UID}
        DJANGO_GROUP=${RUNNER_GID}
        WADS_CONTAINER_PREFIX=smoke
        WADS_SITE_URL=localhost
      setup-commands: |
        django: python manage.py makemigrations --no-input && python manage.py migrate --no-input
        django: python manage.py collectstatic --no-input
      check-env: |
        HEALTH_PATH=/healthz/
```

Why each input is needed:

* **`base-url: https://localhost`** and **`insecure-tls: true`**: in production mode nginx redirects HTTP to HTTPS, using a certificate made with `mkcert` that the runner does not trust.
* **`ready-path: /healthz/`**: the template's health endpoint. Older sites without one can leave this as `/`.
* **`env-template`**: the template's name varies between sites: `.env.dist.template`, `.env.template`, `.env.dist`, or for some sites `.env.production.template`.
* **`DJANGO_USER` and `DJANGO_GROUP`**: the Django image creates a user with these IDs, which must match the runner's so the container can write to the checked-out `siteroot`.
  `${RUNNER_UID}` and `${RUNNER_GID}` are filled in by the action.
* **`WADS_CONTAINER_PREFIX`**: names the containers, networks and volumes.
* **`WADS_SITE_URL=localhost`**: Django's `ALLOWED_HOSTS` comes from this, so it must match the host in `base-url`, otherwise every request is rejected with HTTP 400.
  The template's other URL settings are derived from it, which is why `env-values` replaces keys where they are in the file rather than adding them at the end.
* **`setup-commands`**: production mode does not run migrations or `collectstatic` by itself; the action runs them as the wiki's deployment steps do, after `docker compose up`.
  The template does not commit its migrations, so they are made first; drop `makemigrations` for sites that commit theirs.
* The database password and secret key are random values created by the action (`generate-secrets`).
  Any other secrets a site declares, such as reCAPTCHA or map API keys, also get random values, so features using them will not work, but the site will start.

These inputs are supported for the template and for sites that keep close to it.
These inputs were tested against the template on 15 October 2026. The template should run this action in its own CI, on pull requests and on a schedule, so that changes to either the template or this action that break the other are caught.

### Other WADS sites

Older sites have drifted from the template in different ways, so they are best effort: start from the inputs above and add what the site needs.
These sites were tested by hand on 15 October 2026, and show the kinds of change needed:

| Site | Result | Changes to the inputs above |
| --- | --- | --- |
| wads-african-cities | Passed | `env-template: .env.template`; drop `makemigrations`; `env-values` also sets `WADS_DB_NAME` and `WADS_DB_USERNAME` (blank in its template) and `WADS_APP_ENV=production` (its template says `dev`). |
| Wagtail-Studiorum | Passed | Drop `makemigrations`; `env-values` also sets `EXTERNAL_DATA_MOUNT=./smoke-data` (a server path otherwise), `TASK_WORKER_TEMP_VOLUME=task-worker-temp`, and `FILEBROWSER_UID`/`FILEBROWSER_GID` to `${RUNNER_UID}`/`${RUNNER_GID}`. |
| wads-decent-work | Passed | `env-template: .env.template`; drop `makemigrations`; `WADS_APP_ENV=deploy`; and an earlier step creating a self-signed certificate where its nginx image expects a real one (see below). |
| wads-wagtail-cmm | Failed: site problem | Starts with `env-template: .env.local.template`, `WADS_APP_ENV=deploy` and a certificate mounted through an extra Compose file (see below), but its 404 page gives a 500 on a fresh database. |
| WADS-Wagtail-Dialectics | Failed: site problem | Needs `env-template: .env.dist` and `poetry run python manage.py ...` setup commands, but a data migration expects production data, so `migrate` fails on a fresh database. |
| wads-carbon-cost | Failed: site problem | Its pgRouting image no longer builds, as the PostgreSQL apt repository for Debian bullseye it uses has been retired. |

All of these runs also set `WADS_DB_NAME=smoke_db` and `WADS_DB_USERNAME=smoke_user`, which is harmless where a template already sets them.
A failure marked "site problem" means the site cannot be started from a clean checkout, which would equally affect a new developer or a fresh deployment.

Sites whose production nginx copies real certificates from `.docker/nginx/certs/` need a self-signed one under the same name, created by a step before this action:

```yml
  - name: Create a stand-in certificate
    run: |
      mkdir -p .docker/nginx/certs
      openssl req -x509 -newkey rsa:2048 -nodes -days 1 -subj "/CN=localhost" \
        -keyout .docker/nginx/certs/example.manchester.ac.uk.key \
        -out .docker/nginx/certs/example.manchester.ac.uk.crt
```

If the certificates come from a Docker volume instead, write them to another folder and mount it over the volume with an extra Compose file, created by the same step and added through `compose-files` after the site's own files:

```yml
services:
  nginx:
    volumes:
      - ./smoke-certs:/etc/nginx/certs:ro
```

## Checks

`app-kind` chooses a bundled check.
The ones most useful here are:

### `django`

For Django apps.
Run `migrate` and `collectstatic` (if static files are served by another container) in `setup-commands` first.

Checks that:

* the home page (`/`) does not give an error other than 401, 403 or 404 (a fresh database may have no home page, or it may need a login). Redirects are accepted; a 400 fails with a hint about `ALLOWED_HOSTS`;
* `HEALTH_PATH`, if set, returns 200;
* the admin login page returns 200 and has a login form, which needs the database, templates and static files to work;
* every local script and stylesheet the admin page links loads, which checks static files are being served (e.g. by nginx);
* an unknown path (`/smoke-test/no-such-page/`) returns 404;
* the admin login page returns 200 ten times over, with a new connection each time;
* the `app-service` container has not logged a Python traceback.

| Setting | Default | Meaning |
| --- | --- | --- |
| `ADMIN_PATH` | `/admin/login/` | The admin login page. Wagtail sites often move Django's own admin to `/django-admin/`. |
| `HEALTH_PATH` | _(none)_ | A path that must return 200. |

### `wagtail`

For Wagtail sites.
The same as `django`, and also checks the admin login page is Wagtail's.

### Other kinds

`fastapi`, `flask`, `shiny`, `static` and `streamlit` are also available, for when such an app runs alongside other services.
See [`docker-web-smoke-test`](../docker-web-smoke-test#app-kinds) for what each checks.

Settings for the check are passed through `check-env`, one `KEY=value` per line.

## Your own check script

Pass a script, relative to the repository root, as `check-script`.
It is run with `bash` from the repository root, with these environment variables set:

* `BASE_URL`: the `base-url` input
* `CONTAINER_NAME`: the ID of the `app-service` container, if given, for `docker logs` or `docker exec`
* `APP_KIND`: the `app-kind` input, if given
* `INSECURE_TLS`: `true` if `insecure-tls` is set
* anything listed in `check-env`

A non-zero exit fails the job.
The bundled [`docker_smoke_check.sh`](../docker-web-smoke-test/docker_smoke_check.sh) is a good starting point; see [`docker-web-smoke-test`](../docker-web-smoke-test#your-own-check-script).

## Inputs

### Commonly Needed

* `base-url`

  Where the stack is reached from the runner, through a port it publishes, e.g. `http://localhost:8000` or `https://localhost`. Defaults to `http://localhost`. **Optional.**

* `app-kind`

  Run the bundled check for this kind of app: `django`, `wagtail`, `fastapi`, `flask`, `shiny`, `static` or `streamlit`. Also passed to `check-script` as `APP_KIND` if both are given. **Optional.**

* `app-service`

  The Compose service running the app, e.g. `django`. Its container is passed to the check as `CONTAINER_NAME`, so that its logs can be checked for errors. **Optional.**

* `setup-commands`

  Commands to run once the stack has started, one per line as `service: command`, e.g. `django: python manage.py migrate --no-input`. Each runs with `sh -c` in that service's running container (`docker compose exec`). A failing command is retried every 5 seconds, so commands should be safe to repeat, as `migrate` and `collectstatic` are; a command that has not succeeded within `setup-timeout` (including one that hangs) fails the job. Afterwards each service that ran a command is restarted. **Optional.**

* `env-template`

  A file to copy to `.env` before starting, e.g. `.env.dist.template`. Overwrites any existing `.env`. **Optional.**

* `env-values`

  Values to set in `.env`, one `KEY=value` per line. A key already in the file is replaced where it is, so later lines that use it as `${KEY}` pick up the new value; other keys are added at the end. `${RUNNER_UID}` and `${RUNNER_GID}` in a value are replaced with the user and group IDs running the job. Only the keys are printed in the log. **Optional.**

* `check-script`

  Your own check script, relative to the repository root. Takes precedence over the bundled check. **Optional.**

* `check-env`

  Extra environment variables for the check, one `KEY=value` per line. Values may contain spaces. **Optional.**

* `ready-path`

  Path that must respond without an error (status below 400; redirects count) once the stack is up. Defaults to `/`. **Optional.**

* `insecure-tls`

  Accept a self-signed HTTPS certificate when waiting for and checking the stack. Defaults to `false`. **Optional.**

### Less Commonly Needed

* `compose-files`

  Compose files to use, one per line, e.g. `compose.yaml` and `compose.staging.yaml`. Defaults to Compose's own choice: `compose.yaml` plus `compose.override.yaml` if present. **Optional.**

* `working-directory`

  Directory containing the Compose files, relative to the repository root. Defaults to `.`. **Optional.**

* `generate-secrets`

  Create any file-based Compose secrets that do not exist yet, filled with random values. Defaults to `true`. **Optional.**

* `setup-timeout`

  Seconds each setup command may take, including retries while it fails. A command still running at the end is stopped. Defaults to `300`. **Optional.**

* `ready-timeout`

  Seconds to wait for `ready-path` to respond after the stack starts. Defaults to `120`. **Optional.**

* `reclaim-disk`

  Free disk space before building by removing all unused Docker images, volumes and build cache on the machine running the job. Defaults to `false`. **Optional.**

  Turn this on if a large stack fails to build on a GitHub-hosted runner with "no space left on device".
  GitHub-hosted runners have limited free disk space, partly because of the Docker images preinstalled on them, and each job gets a fresh runner that is thrown away afterwards, so clearing them is safe.

  Leave it off anywhere else.
  On a self-hosted runner, or when running the workflow locally (e.g. with [act](https://github.com/nektos/act)), the job runs on a machine that is kept between runs, and this would delete that machine's own Docker images, volumes and build cache.

## Outputs

None.

## Permissions

The action itself needs no `GITHUB_TOKEN` permissions.
Checking out the repository first needs:

```yml
contents: read
```
