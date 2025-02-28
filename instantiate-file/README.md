# Instantiate Value as File

Instantiates a value (presumably a secret) as a temporary file.
This action is careful to delete the file later in the workflow (after it shouldn't be required any more).

Example:
```yml
      - uses: UoMResearchIT/actions/instantiate-file@main
        id: mkfile
        with:
          value: SGVsbG8sIHdvcmxkLg==
            # The base64-encoded form of "Hello, World."
          base64: true
      - run: cat $TempFile
        env:
          TempFile: ${{ steps.mkfile.outputs.filename }}
        # Prints "Hello, World."
```
This action is intended for use with secrets, making them available to later workflow steps that expect them
in files:
```yml
      - uses: UoMResearchIT/actions/instantiate-file@main
        with:
          value: ${{ secrets.ENCODED_PRIVATE_KEY }}
          filename: privateKey.pem
          base64: true
```
It's recommended that non-secret information be held in the `vars` context. See the Github documentation for more information.

## Inputs
* `value`

  The value to instantiate. **Required.**

* `filename`

  The file to write to. If unspecified, a temporary file is used. **Optional.**

* `base64`

  If `true`, the value should be base64-decoded before being written to the file.
  If `false` (the default), the value is assumed to be raw text. **Optional.**

## Outputs
* `filename`

  The full pathname of the file that the value was written to, unless that was overridden by the user in which case it is the same as the `filename` input.

## Permissions
No special permissions required.
