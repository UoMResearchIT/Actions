# Contributing to these Actions

These Actions are owned by the [Automation Working Group](https://github.com/UoMResearchIT/RSE-Continuous-Improvement/wiki/Automation-Working-Group) at the University of Manchester's [Research Software Engineering](https://research-it.manchester.ac.uk/services/research-software-engineering/) department. We're very happy to accept contributions from other parts of the University, provided those are contributions of reusable Actions that stand a chance of being useful across many projects or reports of issues (whether requests for new Actions or bug reports).

Contributions of code are not normally accepted from outside the University.

Contributions of bug reports are welcome from outside the University.

## Guidelines for a Good Action

A good Action ***should*** be:
* Slightly tricky to get right. Just calling `mkdir foo` doesn't need a special Action!
  * Anything extremely tricky to get right is probably too complex for an Action in the first place.
* Usable in more than one place; we do not want to encode particular ways of working too strongly in this repository's Actions, as the University has far too much variation there.
* Documented in its `README`, especially:
  * A __summary__ sentence or more, to explain at a glance why one might use the Action.
  * At least one __example__. It doesn't need to cover anything fancy, but it does need to cover the least one could do to make use of the Action, to let a user of the Action get started easily.
  * Whether the Action needs a __specific runner__. If any runner will do (sometimes a good reason for making an Action is to encourage portability) then the Action should be tested on all three main runner types.
  * What its __inputs and outputs__ are, if any (NB: if a security token _other than the Github token_ is required by the Action, it _must_ be presented via an input).
  * Whether any __special permissions__ need to be granted to the Github token.
* Self-contained so that dependencies are not assumed, unless you document that they're required.

Actions _may_ use other Actions, but there is a maximum depth, so it's not recommended to make this particularly deep.

Lack of documentation or documentation that is at variance with what the Action does is considered to be a **BUG** and should be reported as such.

## Guidelines for Reviewing

The guidelines for a good Action outlined above should be borne in mind when reviewing.

A contribution to this repository _should not_ be accepted unless it is understood fully. This is particularly important for any contribution to any Action that requires any form of non-standard security token or elevated privileges.

# See Also
* [Teams Chat](https://teams.microsoft.com/l/message/19:8b39cf4dd3c544c88fa1e6be1c978839@thread.v2/1739808070861?context=%7B%22contextType%22%3A%22chat%22%7D).

> [!NOTE]
> Some links _on this page_ will not resolve for people outside the University. We know.
