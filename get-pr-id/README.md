# Get the PR number for the current commit

Given the current commit, determine the PR number associated with it.
Handles the case when there is no such PR.

This is expected to be used on a `push` or `pull_request` trigger.

Example:
```yml
      - uses: UoMResearchIT/actions/get-pr-id@get-pr-id
        id: pr
      - run: echo PR=$PR
        env:
          PR: ${{ steps.pr.outputs.pr }}
```

## Inputs
None

## Outputs
* `pr`

  The PR number, or an empty string if the current event doesn't have a commit SHA that corresponds to a pull request.

## Permissions
Requires: `pull-requests: read`.
