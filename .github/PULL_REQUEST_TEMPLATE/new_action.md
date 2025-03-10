---
name: ⭐ New Action
about: File a bug/issue
title: '[FRQ]: '
labels: enhancement ⭐
type: Feature
---

<!--
Hi there!

Thanks for helping to contribute to this repository.
Your contribution is very much appreciated.

Donal Fellows (@dkfellows) on behalf of University of Manchester Research Software Engineering.
-->

<!--
Here's a few things to think about when writing a PR:
-->

- [ ] Is this fixing an issue? If so, please `#ref` its ID. This helps a lot! (Note that an issue is _not_ required for submitting a new action.)

- [ ] What do you think this action does? We can see what it _actually_ does by reading the code,
      but it's very helpful to have a short description of what you _intend_ it to do.

- [ ] Have you considered whether there is an existing action by some other reasonably-trusted party to do this?

- [ ] If you can, `@` mention someone to review the code at least in the first instance.
      Or, if you have permission, just directly request a review from them.

- [ ] Do you have new bash scripts in your PR? Did you remember to mark them as executable?

    On Windows, this needs:

    ```bash
    git update-index --chmod=+x path/to/file.bash
    ```

    On Linux and macOS, just `chmod +x path/to/file.bash` before doing `git add`.

- [ ] Don't forget to give your action a `README.md`.

    Action `README`s should typically follow a simple pattern (see our existing actions for real instances):

    ```markdown
    # Title

    Description (often copied from the action descriptor).

    Basic Example(s); how do people get started.

    > [!NOTE]
    > Platform requirements (if any).

    ## Inputs

    * `name`

        Description. **REQUIRED/OPTIONAL.**

    ## Outputs

    * `name`

        Description.

    ## Permissions

    What permissions the `GITHUB_TOKEN` needs, or a statement that it doesn't need any.

    # Examples

    If you need more complex examples (especially in context with other actions),
    put them towards the end. For simple actions, you can probably omit this.
    ```

    You can add more sections if you need them; please try to keep them towards the end.

- [ ] Link to your action folder from the main `README.md`.

- [ ] Your action descriptor (`action.yml`) should include
  (as well as the technical data required to implement the action):
  * a `name` (mandatory),
  * a `description` (mandatory),
  * your name(s) in the `author` field, and
  * suitable `branding` metadata.

- [ ] Consider whether your action interacts with itself and other actions.
  * Does it cache things? If so, is there a suitable cache key?
    (Sometimes it is a good idea to let users specify this; other times, that's a bad idea.)
  * Does it need to interact with future calls of itself? Environment variables can help.
  * Do later actions want information from this action? Outputs are perfect for producing that.

  Remember, you can ask for help with these.

- [ ] It helps a lot if you can link to a build log that shows that your action works.
  This is particularly helpful for any action intended to be used across many runner
  platforms.

  Or suggest some other way we can test (such as within our [testing](/actions-test) repo).
