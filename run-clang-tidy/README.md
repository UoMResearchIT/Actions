# Run clang-tidy

Runs clang-tidy against a C or C++ codebase in a given directory. Assumes a Ubuntu runner.

Example usage:

```yml
  - uses: UoMResearchIT/actions/run-clang-tidy@main
```

## Inputs

* `file-glob`

    What files to match for testing, as a pattern. **Optional.**  

    Note that headers typically require additional configuration options to check.
    Default: `*.cpp`

* `options`

    Extra options to pass to clang-tidy. **Optional.**

* `working-directory`

    The working directory to run in. **Optional.**  
    Default: `.`

## Outputs

None.

## Permissions

No special permissions required.
