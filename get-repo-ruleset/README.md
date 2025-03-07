# Get Repository Branch Ruleset

Gets the ruleset applied to a particular branch of a repository.

Example:
```yml
      - uses: UoMResearchIT/actions/get-repo-ruleset@main
        id: rules
      - run: jq . < $THE_FILE
        env:
          THE_FILE: ${{ steps.rules.outputs.filename }}
        # Prints the ruleset
```

> [!NOTE]
> This action produces an error if the ruleset is empty!

> [!NOTE]
> This action is designed to run on Linux runners. It is not supported on other platforms.

## Inputs
* `repository`

  Which repository to fetch the ruleset from.
  Defaults to the repository that the workflow is running in. **Optional.**

* `token`

  Access token used for reading the repository metadata.
  Required if the repository is not the current once. **Optional.**

* `branch`

  Which branch to get the ruleset of.
  If not specified, uses the default branch of the repository. **Optional.**

## Outputs
* `filename`

  The full pathname of the file that contains the retrieved ruleset.

* `ruleset`

  The ruleset as JSON data.

## Permissions
No special permissions required when accessing the current repository's ruleset.
If accessing a different repository, an appropriate PAT will be required.
