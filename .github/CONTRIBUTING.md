# Contributing to these Actions

These actions are owned by the [Automation Working Group](https://github.com/UoMResearchIT/RSE-Continuous-Improvement/wiki/Automation-Working-Group) at the University of Manchester's [Research Software Engineering](https://research-it.manchester.ac.uk/services/research-software-engineering/) department.

Contributions are welcomed from outside, but are prioritised from members of the University.

To contribute, simply raise a Pull Request. 

## Guidelines for a Good Action

A good Action should be:
* Slightly tricky to get right. Just calling `mkdir foo` doesn't need a special action!
* Usable in more than one place.
* Documented in its `README`, especially:
  * At least one example. It doesn't need to cover anything, but it does need to cover the least one could do to make use of the Action.
  * Whether the Action needs a specific runner. If any runner will do (sometimes a good reason for making an Action is to encourage portability) then the Action should be tested on all three main runner types.
  * What its inputs and outputs are, if any (NB: if a security token _other than the Github token_ is required by the Action, it _must_ be presented via an input).
  * Whether any special permissions need to be granted to the Github token.
* Self-contained so that dependencies are not assumed (unless you documented that they're required).

Actions _may_ use other Actions, but there is a maximum depth, so it's not recommended to make this particularly deep.

Lack of documentation or documentation that is at variance with what the Action does is considered to be a **BUG** and should be reported.

## Guidelines for Reviewing

A contribution to this repository _should not_ be accepted unless it is understood fully. This is particularly important for any contribution from someone outside the University, alas, especially for any Action that requires any form of non-standard security token or elevated privileges.

# See Also
* [Teams Chat](https://teams.microsoft.com/l/message/19:8b39cf4dd3c544c88fa1e6be1c978839@thread.v2/1739808070861?context=%7B%22contextType%22%3A%22chat%22%7D).

> [!NOTE]
> Many links _on this page_ will not resolve for people outside the University. We know.
