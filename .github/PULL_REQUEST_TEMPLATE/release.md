---
name: 📦 Release
about: Create a release
title: Release
type: Task
assignees: dkfellows
---

<!--
Hi there!

Thanks for helping to contribute to this repository.
Your contribution is very much appreciated.

Donal Fellows (@dkfellows) on behalf of University of Manchester Research Software Engineering.
-->

Release checklist:

- [ ] Make a `release` branch
- [ ] Make a PR for it <!-- using this template... -->
- [ ] Update version numbers, checking `README.md`s, `action.yml`s, and `bug.yml` in the issue templates
- [ ] Draft the release (filling in release description data, prepping the tag to be set on the `release` branch)
- [ ] Rerun known tests after pointing them at the version to be tagged
- [ ] Make the GitHub release draft into a release
- [ ] Merge the PR and delete the branch
