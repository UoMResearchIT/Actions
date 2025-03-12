# Run a Basic Style Check on C and C++ Code

This runs a [simple style checker](https://github.com/verateam/vera) on a directory containing C and/or C++ code.

> [!NOTE]
> This is not a complex style check; it only catches basic issues _by design._

Example usage:

```yml
  - uses: UoMResearchIT/actions/run-c-style-check@v0.3
    with:
      base-dir: src
```

> [!IMPORTANT]
> Only supported on Ubuntu runners.

## Inputs

* `base-dir`

  The name of the base directory containing the sources to check. **Required.**

  Example: `src`

* `file-pattern`

  What files to process. This is a regular expression to pass to `egrep`. **Optional.**

  Default: `.c$|.h$|.cpp$|.hpp$` (C and C++ files following ordinary conventions)

* `profile`

  Which profile to use. **Optional.**

  Two current profiles are supported:

  * `std` (the default profile)
  * `with-asm` (for code that makes use of inline assembly)

* `options`

    Extra options to pass to  the tool `vera++`. **Optional.**  
    No options by default.

* `skip-dir`:

  The name of a subdirectory of the `base-dir` that contains code that should be skipped. **Optional.**

  Example: `generated-code`

## Outputs

None.

## Permissions

No special permissions required.
