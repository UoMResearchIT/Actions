# Check Copyrights and Licenses

Uses [Apache RAT](https://creadur.apache.org/rat/index.html) to verify that all files have appropriate copyright declarations and license statements.

This task does _not_ validate that all files have copyright declarations that match your project's policy for what they _should be_, just that they're all there and that the licenses are what you tell the task it should be. You are responsible for ensuring that the subtle difference between these two things are smoothed over.

Note that, in general, all public files with a suitable human-readable comment format should have a copyright notice and license declaration in a comment towards the front of the file.

## Inputs

* `version`

    The version of Apache RAT to use. **Optional.**

    Example: `0.14`

* `mirror`

    The mirror of the Apache download site to get the library from. **Optional.**

    Examples: `https://www.apache.org/dyn/closer.cgi?action=download&filename=`,
    `https://www.mirrorservice.org/sites/ftp.apache.org/`

* `config_file`

    Which configuration file to use. This is _actually_ the name of an ANT build file in the same directory as this README that runs RAT. **Optional.**

    Supported options are:
    * `rat.xml` &mdash; All license acceptable to RAT. This is default.
    * `rat_asl20.xml` &mdash; Only the Apache Software License 2.0.
    * `rat_gpl3.xml` &mdash; Only the GNU General Public License version 3.

    When writing a new file to use in this option (PRs accepted), please copy the `rat.xml` or `rat_asl20.xml` file and modify the contents of the `<rat:report>` element to adjust how the matching is done. You should consult [the RAT documentation](https://creadur.apache.org/rat/apache-rat-tasks/types.html) for how to do it, especially when matching a non-standard license.

## Outputs

None.

## Permissions

No special permissions required.
