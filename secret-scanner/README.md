# Secret Scanner
Runs [detect-secrets](https://github.com/Yelp/detect-secrets) to detect secrets in the codebase that has already been checked out into the working directory.

> [!NOTE]
> This is a fork and partial rewrite of [secret-scanner/action](https://github.com/secret-scanner/action). It is only intended to be used from the `scan-for-secrets` reusable workflow in this repository.

> [!IMPORTANT]
> This action will set up Python. It _assumes_ a `ubuntu-latest` runner.

Example basic usage:

```yml
  - uses: UoMResearchIT/actions/secret-scanner@main
    with:
      package: mycode.pkg_name
```

Example usage with spell checking:

```yml
  - uses: UoMResearchIT/actions/secret-scanner@main
    with:
      package: mycode.pkg_name
      language: en_GB
```

## Inputs

* `additional-args`

  Extra arguments to pass to the detect-secret binary. **Optional.**

* `baseline-file`

  A path to the baseline secrets file. **Optional.**

  Defaults to `.github/secret-scanner/baseline.json`

* `python-version`

  The version of python to use. **Optional.**

  Defaults to `3.12`

* `exclude-path`

  A path to the directory of files describing things to exclude. **Optional.**

  Defaults to `.github/secret-scanner`

  The exclusion files in this directory will be called `excluded_files.txt`, `excluded_lines.txt`, and `excluded_secrets.txt`. Each non-blank non-comment line in those files is a regex that will be passed as an argument to the `--exclude-files`, `--exclude-files` or `--exclude-secrets` options to the [underlying library](https://github.com/Yelp/detect-secrets); consult the documentation there for exactly what they do. 

## Outputs

None. Writes to the the summary page if problems are detected.

## Permissions

No permissions required.
