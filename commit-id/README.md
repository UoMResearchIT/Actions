# Generate Commit ID

Write the current commit ID to a file. Intended mainly for workflows triggered by `push` or that otherwise have a meaningful `github.sha`.

It's up to the caller to make and check in the file with the pattern to
replace in it; it is recommended that the pattern string only appear once.
It's assumed that updated file will not be committed back to the repository; this is intended as an immediate pre-build step.

## Example usage
### C and C++

```yml
  - uses: UoMResearchIT/actions/commit-id@0.2
    with:
      file: src/build_id.h
```

Which might be paired with a source file (in `src/build_id.h` for example) like this for C or C++:
```c
/* Do not edit the next line manually. */
#define COMMIT_ID   "undefined (dev build)"
```
### Python
```yml
  - uses: UoMResearchIT/actions/commit-id@0.2
    with:
      file: src/version.py
```
together with the file `src/version.py`:
```py
build_version: str = """undefined (dev build)"""
```

## Inputs

* `file`

  The name of the existing file to process. **Required.**

  Example: `src/build_id.h`

* `pattern`

  The literal substring to replace. **Optional.**  
  Defaults to `undefined (dev build)`

## Outputs

None.
