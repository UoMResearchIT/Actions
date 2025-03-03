<!--
Hi there!

Thanks for helping to contribute to this repository.
Your contribution is very much appreciated.

Donal Fellows (@dkfellows) on behalf of University of Manchester Research Software Engineering.
-->

<!--
Here's a few things to think about when writing a PR:
-->

- [ ] Is this fixing an issue? If so, please `#ref` its ID. This helps a lot!

- [ ] What do you think this PR does? We can see what it _actually_ does by reading the code,
      but it's very helpful to have a short description of what you _intend_ it to do. 

- [ ] If you can, `@` mention someone to review the code at least in the first instance.

- [ ] Do you have new bash scripts in your PR? Did you remember to mark them as executable?

    On Windows, this needs:

    ```bash
    git update-index --chmod=+x path/to/file.bash
    ```

    On Linux and macOS, just `chmod +x path/to/file.bash` before doing `git add`.

- [ ] If you're making a new action, don't forget to give it a `README.md` and to link to the
    action folder from the main `README.md`.

    Action `README`s should typically follow a simple pattern:

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

- [ ] If you're making a new action, your action descriptor (`action.yml`) should include
  (as well as the technical data required to implement the action):
  * a `name`,
  * a `description`,
  * your name in the `author` field, and
  * suitable `branding` metadata.

- [ ] It helps a lot if you can link to a build log that shows that your action works.
  This is particularly helpful for any action intended to be used across many runner
  platforms.
