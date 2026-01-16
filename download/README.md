# Download File

Downloads a file from a URL, using a cached version if possible.

Example:
```yml
  - uses: UoMResearchIT/actions/download@v1.2.1
    with:
      url: https://research-it.manchester.ac.uk/
      local-name: homepage.html
```

Example of accessing a protected resource:
```yml
  - uses: UoMResearchIT/actions/download@v1.2.1
    with:
      url: https://api.github.com/repo/UoMResearchIT/actions=test/contents/README.md
      local-name: read-me.md
      content-type: application/vnd.github.raw+json
      token: ${{ secrets.MY_ACCESS_TOKEN }}
```

> [!TIP]
> If using the `token` input, you almost certainly ought to be getting its value from the
> [GitHub `secrets` context](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions).

> [!WARNING]
> This action can potentially exfiltrate the provided token. You should only provide a token if it is _necessary_ to access the URL, and the token was originally created with the intention that it be used to access that URL. Any pull request involving this action should be reviewed carefully if it provides a token.


# Inputs
* `url`

  The URL to download from. **Required.**

* `local-name`

  The local file name. Derived from the URL if not given.
  _Must_ be supplied if the guessed name would be empty. **Optional.**

* `content-type`

  The content type to try to download.
  Defaults to whatever the server chooses by default. **Optional.**

  Example: `text/html`

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
If a `token` is supplied, whatever that token is must have permission to access the resource concerned.
