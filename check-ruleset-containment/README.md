# Check Whether Ruleset Contains Other Ruleset

Checks whether a ruleset (the "current" ruleset) contains all the rules
from a standard model ruleset (the "expected" ruleset).

Example:
```yml
      - uses: UoMResearchIT/actions/get-repo-ruleset@v1.2.4
        id: get-rules
      - uses: UoMResearchIT/actions/check-ruleset-containment@v1.2.4
        with:
          current: ${{ steps.get-rules.outputs.filename }}
          expected: project_setup/my_ruleset_file.json
		  ignore: '["enforcement", "required_status_checks.strict"]'
```

> [!NOTE]
> This action is designed to run on Linux runners. It is not supported on other platforms.

## Inputs
* `current`

  The name of the file containing the "current" ruleset to check. **Required.**

* `expected`

  The name of the file containing the "expected" ruleset to check against. **Required.**
  
* `ignore`

  A JSON array of parameter paths to ignore when comparing rulesets. **Optional.**
  - Supports nested paths using dot notation (e.g. a.b.c)
  - Ignored parameters are removed from both rulesets before comparison
  - Differences in ignored parameters (including missing keys) are not reported

## Outputs
None.

## Permissions
No special permissions required.
