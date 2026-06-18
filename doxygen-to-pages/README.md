# Doxygen to Pages

Runs [Doxygen](https://doxygen.nl/) and uploads the result as an artifact ready to be deployed to
Github Pages (see [actions/deploy-pages](https://github.com/actions/deploy-pages)).

Example:
```yml
  - uses: UoMResearchIT/actions/doxygen-to-pages@v1.2.6
```

The `Doxyfile` should have these set (these are default values):
```Doxyfile
GENERATE_HTML = YES
HTML_OUTPUT = html
HTML_FILE_EXTENSION = .html
```

When processing the `Doxyfile`, the environment variable `SITE_URL` is set to the location
that the built documentation tree will be deployed to.
If that can't be determined, the environment variable will be set to `https://example.org/`.

> [!NOTE]
> This action assumes it is running on a standard Linux runner.

> [!WARNING]
> This action makes substantive changes to the filesystem which may be intrusive.
> You typically should not have further actions run after this action in the same job;
> putting the deploy in a downstream job is recommended.

> [!TIP]
> An example `Doxyfile` is [here](example/Doxyfile).
> Copy it to your project, and change `PROJECT_NAME`, `PROJECT_NUMBER` and `PROJECT_BRIEF` to get a minimal customisation.

## Inputs
* `working-directory`

  The working directory to run Doxygen in. Where the `Doxyfile` is located. **Optional.**

  Defaults to `.`.

* `publish-environment`

  The environment that will be published to. Defaults to `github-pages`, the usual correct value. **Optional.**

  If this environment is not defined in the repository, a debugging artifact containing the Doxygen output will be attached to the workflow run summary page.

## Outputs
* `artifact_id`

  The ID of the artifact that was uploaded, if it is production-ready. The artifact is _not_ deployed by this action.

* `deploy-ready`

  Whether a deployment is possible from what was uploaded. Either `true` or `false`, as strings.

## Permissions
Requires at least `actions: read` and `contents: read`.
(By contrast, [actions/deploy-pages](https://github.com/actions/deploy-pages)
_requires both_ `pages: write` _and_ `id-token: write`.)
