# Run Pylint
Runs pylint on a Python package. 

> [!NOTE]
> Installing pylint in the environment before this action is up to the caller.

<!--# TODO: Add step to install pylint and other dictionary bits if it isn't already present. -->

Example usage:

```yml
  - uses: UoMResearchIT/actions/run-pylint@main
    with:
      package: mycode.pkg
      language: en_GB
```

## Inputs

* `package`

  The name of the Python package (or packages) to analyse. **Required.**

  Example: `mycode.pkg`

* `disable`

  The messages/categories to disable. **Optional.**

  Default value: `R`

* `jobs`

  The number of Python processes to use. **Optional.**

  Default value: `1`

* `rcfile`

  The name of the pylint rc file. **Optional.**

  Default value: `global_relaxed`

  `global_relaxed` and `global_strict` will use files in support scripts.
  Any other value is interpreted as the name of a file in the job workspace.

* `exitcheck`

  The combined results code to fail on (as a bit mask). **Optional.**

  Default value: `6`  (Action fails on `ERROR` or `WARNING`)

  Pylint uses a bit mask to encode exit codes; it should leave with following status codes:

  * 0 if everything went fine
  * 1 if a fatal message was issued
  * 2 if an error message was issued
  * 4 if a warning message was issued
  * 8 if a refactor message was issued
  * 16 if a convention message was issued
  * 32 on usage error

  This action *always* dies on Fatal or Usage messages; both indicate different types of critical problem,
  either with the code being checked or the way in which the tool was called.

* `language`

  The (human) language to use for spell checking. Omit to disable the spell check (default). **Optional.**

  Example: `en_GB` (use a UK English dictionary)

* `dictionary`

  The custom dictionary to use for spell checking. **Optional.**

  Default: `.pylint_dict.txt`

## Outputs

* `result`

  The decoded set of summary issues found in the pylint call,
  including ones not otherwise deemed fatal. Empty on complete success.

  Example: `refactor convention `

## Permissions

No special permissions required.
