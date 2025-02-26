# Publish Image to Docker Repository

Publishes the current Docker image to the container registry run by Github.
This action does _not_ create the local image.

Example usage:

```yml
  - uses: UoMResearchIT/actions/docker-publish@main
    with:
      source-tag: testing
      version: latest
```

> [!NOTE]
> Assumes you are using a Linux container.

## Inputs

* `actor`

  Who is publishing. Defaults to who initiated the workflow run. **Optional.**

* `container-name`

  The name of the container. Defaults to the nanme of the repository. **Optional.**

* `organisation-name`

  The name of the organisation.
  Defaults to the name of the organisation that owns the repository running this action.
  **Optional.**

* `source-tag`

  The source tag of the local repository. Defaults to `testing`. **Optional.**

* `token`

  An alternate security token. Leave blank to use the `GITHUB_TOKEN`. **Optional.**

* `version`

  The ID of the version to publish. Defaults to `latest` if not specified. **Optional.**

* `imageid`

  The ID of the build to publish. If specified, this takes precedence over local image discovery. **Optional.**

## Outputs

* `name`

  The computed name of the pushed image.

## Permissions

Pushing to the Github container registry using the `GITHUB_TOKEN` requires the permission:
```yml
packages: write
```
If you are using a PAT or publishing to another registry, no special workflow permissions are otherwise required (but you have to override the `token` in these cases anyway).
