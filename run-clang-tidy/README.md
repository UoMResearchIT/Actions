# Run clang-tidy

Runs [clang-tidy](https://clang.llvm.org/extra/clang-tidy/) against a C or C++ codebase in a given directory.

Example usage:

```yml
  - uses: UoMResearchIT/actions/run-clang-tidy@v0.3
```

> [!IMPORTANT]
> Assumes that it is being run in an Ubuntu-based runner.

## Inputs

* `config-file`

    The path to the configuration file, if not using the predefined profile.
    Relative filenames are resolved relative to `working-directory`. **Optional.**

    Example: `../.clang-tidy`

* `file-glob`

    What files to match for testing, as a pattern. **Optional.**  

    Note that headers typically require additional configuration options to check.
    See the documentation for details.  
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
