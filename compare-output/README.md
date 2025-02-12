# Compare program output to a string

Compare the output of a program to a string given as a parameter.
A single trailing newline will be ignored.
The command is run by bash on Linux and macOS, and by PowerShell on Windows.

The action is successful if the output of the `command` is equal to the string given in `expected`.

The expected and actual outputs are written to the log to aid debugging of failures.

Example usage:

```yml
  - uses: UoMResearchIT/actions/compare-output@0.1
    with:
      command: echo foo
      expected: foo
```

## Inputs

* `command`

  The command to get the output of for comparison. **Required.**

  Example: `echo Foo Bar`

* `expected`

  The string that the output is expected to equal. **Required.**

  Example: `Foo Bar`

* `init`

  Extra initialisation code to run before the command to compare. **Optional.**

  Example: `source someScript.sh`

* `shell`

  Which shell to use to run the program.
  May be `bash`, `pwsh`, or `auto` (the default) to pick based on the runner's platform.  **Optional.**

  Example: `bash`

* `working-directory`

  The working directory to run in.
  Defaults to the job's main working directory.
  **Optional.**

  Example: `./my-build-dir`

## Outputs

None.
