# Run apt-get to install Debian/Ubuntu packages

Installs packages on a Debian or Ubuntu runner. Does not support any other OS, but handles a few nuances of some packages that are fussy about their installation.

Example usage:

```yml
  - uses: UoMResearchIT/actions/apt-get-install@v1.2.7
    with:
      packages: vera++
```

> [!NOTE]
> If you want to source a package from a PPA, you must call [`add-apt-repository`](https://manpages.debian.org/unstable/software-properties-common/add-apt-repository.1.en.html) _before_ calling this action. This action assumes that the source list is already configured.

## Inputs

* `packages`

  The space-separated list of packages to install. **Required.**

  Example (two documentation tools): `doxygen python3-sphinx`

## Outputs

None.

## Permissions

No special permissions required.
