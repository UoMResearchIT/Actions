# List Deployment Environments

Gets the list of deployment environments that the current repository knows about.

Example:
```yml
  - uses: UoMResearchIT/actions/list-environments@list-envs
    id: list
```

## Inputs
* `token`

  An alternative token to use to access the Github API endpoint. **Optional.**

  Defaults to the `GITHUB_TOKEN`.

## Outputs
* `environments`

  A JSON list of all environment names, as a string.

## Permissions
Requires at least `actions: read`, and very likely `contents: read` implicitly as well
(because it must be run within a checkout).
