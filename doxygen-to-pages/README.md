# Doxygen to Pages

Runs Doxygen and uploads the result as an artifact ready to be deployed to
Github Pages (see [actions/deploy-pages](https://github.com/actions/deploy-pages)).

Example:
```yml
  - uses: UoMResearchIT/actions/doxygen-to-pages@main
```

The `Doxyfile` should have these set (these are default values):
```Doxyfile
GENERATE_HTML = YES
HTML_OUTPUT = html
HTML_FILE_EXTENSION = .html
```

When processing the `Doxyfile`, the environment variable `SITE_URL` is set to the location
that the built documentation tree will be deployed to.

> [!NOTE]
> This action assumes it is running on a standard Linux runner.

> [!WARNING]
> This action makes substantive changes to the filesystem which may be intrusive.
> You typically should not have further actions run after this action in the same job;
> putting the deploy in a downstream job is recommended.

## Inputs
* `working-directory`

  The working directory to run Doxygen in. Where the `Doxyfile` is located. **Optional.**

  Defaults to `.`.

## Outputs
* `artifact_id`

  The ID of the artifact that was uploaded. The artifact is _not_ deployed by this action.

## Permissions
Requires _at least_ `pages: read`.
(By contrast, [actions/deploy-pages](https://github.com/actions/deploy-pages)
_requires both_ `pages: write` _and_ `it-token: write`.)
