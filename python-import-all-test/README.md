# Python Import All Test

Runs a simple test to import all the Python files beneath a particular module.
Useful for smoke-testing whether there are import loops;
a common failing of Python IDEs is that they're poor at finding import loops.

Assumes that Python has already been set up.

Example usage:
```yml
  - uses: UoMResearchIT/actions/python-import-all-test@main
    with:
      module: mymodule
```

## Inputs

* `module`

  The name of the module to start the search at. _Not_ a filename.  **Required.**

  Example: `foo.gorp`

* `exclusions`

  Comma-separated list of names of modules to ignore. **Optional.**

  Example: `foo.bar, foo.grill`

* `remove-pyc-files`

  Whether to remove any `.pyc` files present. Not normally required by CI. **Optional.**

  Defaults to `false`.

* `python-root`

  Root of where to find Python packages.
  Only needed if the code has not already been installed locally. **Optional.**

  Defaults to `.`

## Outputs
None.

## Permissions
No special permissions required.
