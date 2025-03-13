# Download File

Downloads a file from a URL, using a cached version if possible.

Example:
```yml
  - uses: UoMResearchIT/actions/download@v0.3
    with:
      url: https://research-it.manchester.ac.uk/
      local-name: homepage.html
```

> [!WARNING]
> If using the `token` input, you almost certainly ought to be getting its value from the
> [GitHub `secrets` context](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions).

# Inputs
* `url`

  The URL to download from. **Required.**

* `local-name`

  The local file name. Derived from the URL if not given.
  _Must_ be supplied if the guessed name would be empty. **Optional.**

* `token`

  A bearer token to present to authorise the download.
  If not supplied, only public resources may be accessed. **Optional.**

  Example: `${{ secrets.GITHUB_TOKEN }}`

* `wget-options`

  Additional options to pass to `wget`. **Optional.**

# Outputs
* `filename`

  The full path to the file.

# Permissions
No special permissions required.
