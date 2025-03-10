---
name: 🐞 Bug
about: File a bug/issue
title: '[BUG]: '
labels: bug 🐛
type: Bug
---

<!--
Hi there!

Thanks for helping to contribute to this repository.
Your contribution is very much appreciated.

Donal Fellows (@dkfellows) on behalf of University of Manchester Research Software Engineering.
-->

<!--
Here's a few things to think about when writing a PR that fixes a bug:
-->

- [ ] Have you put a `#ref` to the issue that this PR fixes? This helps a lot! 

- [ ] What do you think this bug fix does? We can see what it _actually_ does by reading the code,
      but it's very helpful to have a short description of what you _intend_ it to do. 
      If that's essentially just fixing the referenced issue, the reference plus a short sentence suffices.

- [ ] If you can, `@` mention someone to review the code at least in the first instance.
      Or, if you have permission, request a review from them directly.

- [ ] Do you have new bash scripts in your PR? Did you remember to mark them as executable? <!-- If not, just delete this checklist item. -->

    On Windows, this needs:

    ```bash
    git update-index --chmod=+x path/to/file.bash
    ```

    On Linux and macOS, just `chmod +x path/to/file.bash` before doing `git add`.
