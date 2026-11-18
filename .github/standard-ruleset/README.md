# Standard Ruleset

[`ruleset.json`](ruleset.json) is the standard set of branch rules that the
[`check-ruleset`](../workflows/check-ruleset.yaml) reusable workflow checks
repositories against.

It is a public copy of the rules defined by
[`UoMResearchIT/RSE-Repository-Template`](https://github.com/UoMResearchIT/RSE-Repository-Template)
on its `main` branch. Keeping a copy here means `check-ruleset` can run in any
organisation without a token that can read the template, which is private.

Only the template's own rules are included. Rules inherited from the
organisation or the enterprise are left out, and so are the `ruleset_id` and
`ruleset_source*` fields, because
[`check-ruleset-containment`](../../check-ruleset-containment) only compares
each rule's `type` and `parameters`.

The file is versioned with the rest of this repository: `check-ruleset` reads
it from the same commit as the workflow itself, so callers that pin the
workflow to a release also pin the standard.

## Updating

This file is not updated automatically. When the template's branch rules
change, regenerate it with a token that can read the template (for example
your own `gh` login) and open a pull request with the result:

```bash
bash .github/standard-ruleset/export.bash
```

Repositories calling `check-ruleset` from `main` are checked against the new
rules as soon as that pull request is merged.
