# Configure NuGet for Github

This configures NuGet so that it can access the organisation namespace for packages.

Example:
```yml
  - uses: UoMResearchIT/actions/configure-nuget-for-github@v1.0
```

# inputs
* `namespace`

  The namespace to access or publish into. **Optional.**

  Defaults to the name owner of the repository.

* `short-handle`

  The name of the short handle to associated with the Github-hosted repository. **Optional.**

  Defaults to `github`.

# outputs
None

# Permissions
_Technically_ not required, but `packages: read` or `packages: write` are _strongly recommended_ (depending on usage scenario).
