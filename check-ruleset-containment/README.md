# Check Whether Ruleset Contains Other Ruleset

Checks whether a ruleset (the "current" ruleset) contains all the rules
from a standard model ruleset (the "expected" ruleset).

Example:
```yml
      - uses: UoMResearchIT/actions/get-repo-ruleset@main
        id: get-rules
      - uses: UoMResearchIT/actions/check-ruleset-containment@main
        with:
          current: ${{ steps.get-rules.outputs.filename }}
          expected: project_setup/my_ruleset_file.json
```

> [!NOTE]
> This action is designed to run on Linux runners. It is not supported on other platforms.

## Inputs
* `current`

  The name of the file containing the "current" ruleset to check. **Required.**

* `expected`

  The name of the file containing the "expected" ruleset to check against. **Required.**

## Outputs
None.

## Permissions
No special permissions required.
