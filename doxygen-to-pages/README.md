# Doxygen to Pages

Runs [Doxygen](https://doxygen.nl/) and uploads the result as an artifact ready to be deployed to
Github Pages (see [actions/deploy-pages](https://github.com/actions/deploy-pages)).

Example:
```yml
  - uses: UoMResearchIT/actions/doxygen-to-pages@v1.0
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

## Outputs
* `artifact_id`

  The ID of the artifact that was uploaded. The artifact is _not_ deployed by this action.

## Permissions
Requires at least `pages: read` if a meaningful site URL is to be provided.
(By contrast, [actions/deploy-pages](https://github.com/actions/deploy-pages)
_requires both_ `pages: write` _and_ `it-token: write`.)

If not deploying (i.e., because you are going to download the artifact to examine it locally), no special permissions are required.
