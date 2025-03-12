# Download File

Downloads a file from a URL, using a cached version if possible.

Example:
```yml
  - uses: UoMResearchIT/actions/download@v0.3
    with:
      url: https://research-it.manchester.ac.uk/
      local-name: homepage.html
```

# inputs
* `url`

  The URL to download from. **Required.**

* `local-name`

  The local file name. Derived from the URL if not given.
  _Must_ be supplied if the guessed name would be empty. **Optional.**

* `wget-options`

  Additional options to pass to `wget`. **Optional.**

# outputs
* `filename`

  The full path to the file.

# Permissions
No special permissions required.
