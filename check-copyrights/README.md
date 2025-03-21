# Check Copyrights and Licenses

Uses [Apache RAT](https://creadur.apache.org/rat/index.html) to verify that all files have appropriate copyright declarations and license statements.

This task does _not_ validate that all files have copyright declarations that match your project's policy for what they _should be_, just that they're all there and that the licenses are what you tell the task it should be. You are responsible for ensuring that the subtle difference between these two things are smoothed over.

Note that, in general, all public files with a suitable human-readable comment format should have a copyright notice and license declaration in a comment towards the front of the file.

Example usage:

```yml
    - uses: UoMResearchIT/actions/check-copyrights@v0.3
      with:
        profile: ASL
```

> [!TIP]
> It's easiest to either supply no configuration options, or the `profile`.

> [!WARNING]
> License choices can have legal implications. Consult with your project and/or line management, _especially_ if not using a standard profile.

## Inputs

* `version`

    The version of Apache RAT to use. **Optional.**

    Example: `0.15`

* `mirror`

    The mirror of the Apache download site to get the library from. **Optional.**

    Examples: `https://www.apache.org/dyn/closer.cgi?action=download&filename=`,
    `https://www.mirrorservice.org/sites/ftp.apache.org/`

* `profile`

    Which profile to use. The profile decides which license(s) are acceptable. **Optional.**

    If omitted, the `config-file` option is used, or a default that accepts any standard license is used.

    Known profiles:

    * `ASL` &mdash; Apache Software License 2.0
    * `BSD` &mdash; Modified BSD 3-clause License
    * `GPL3` &mdash; GNU General Public License version 3
    * `MIT` &mdash; MIT License

* `config-file`

    Which configuration file to use. This is _actually_ the name of an ANT build file that calls RAT. **Optional.**

    Supported legacy options are:
    * `rat.xml` &mdash; All license acceptable to RAT. This is default.
    * `rat_asl20.xml` &mdash; Only the Apache Software License 2.0.
    * `rat_gpl3.xml` &mdash; Only the GNU General Public License version 3.

    If supplying your own, you are _recommended_ to make it explicitly absolute by prefixing
    with the `GITHUB_WORKSPACE` environment variable.

* `excludes-file`

    The name of the file describing what files should not be checked.
    Defaults to the `.ratexcludes` file in the root of your project. (This is ignored if there is no such file.)

    You don't normally need to specify this unless you have an excludes file with a different name.

## Outputs

None.

## Permissions

No special permissions required.

## Caches

Creates a cache in the overall workflow context with the key `apache-rat-${version}` to avoid hammering selected rate-limited services. This may be safely deleted if desired, but the cache is notably faster than a fresh download.

# See Also

* [`UoMResearchIT/actions/reuse`](../reuse) for an alternate license enforcement scheme.
