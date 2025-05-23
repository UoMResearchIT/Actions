# Run apt-get to install Debian/Ubuntu packages

Installs packages on a Debian or Ubuntu runner. Does not support any other OS, but handles a few nuances of some packages that are fussy about their installation.

Example usage:

```yml
  - uses: UoMResearchIT/actions/apt-get-install@v1.0
    with:
      packages: vera++
```

## Inputs

* `packages`

  The space-separated list of packages to install. **Required.**

  Example (two documentation tools): `doxygen python3-sphinx`

## Outputs

None.

## Permissions

No special permissions required.
