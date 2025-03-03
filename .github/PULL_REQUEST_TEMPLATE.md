<!--
Hi there!

Thanks for helping to contribute to this repository.
Your contribution is very much appreciated.

Donal Fellows (@dkfellows) on behalf of University of Manchester Research Software Engineering.
-->

<!--
Here's a few things to think about when writing a PR:
-->

- [ ] Is this fixing an issue? If so, please #ref its ID. This helps a lot!

- [ ] What do you think this PR does? We can see what it actually does by reading the code,
      but it's very helpful to have a short description of what you intend it to do. 

- [ ] If you can, `@` mention someone to review the code at least in the first instance.

- [ ] Do you have bash scripts in your PR? Did you remember to mark them as executable?

      HINT: On Windows, this needs:
      ```bash
          git update-index --chmod=+x path/to/file.bash
      ```

- [ ] If you're making a new action, don't forget to give it a README and to link to the
      action folder from the main README.

      Action READMEs follow a simple pattern:

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

        What permissions the GITHUB_TOKEN needs, or a statement that it doesn't need any.

        # Examples

        If you need more complex examples (especially in context with other actions),
        put them towards the end. For simple actions, you can probably omit this.
      ```

- [ ] It helps a lot if you can link to a build log that shows that your action works.
