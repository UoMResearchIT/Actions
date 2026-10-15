# Draft a release from a merged PR

Releases are represented by a PR from `development` (or a `hotfix/*` branch, for urgent fixes) into `main`. This action checks such a PR while it is open, so that problems can be fixed before it is merged, and creates the GitHub release once it has been merged.

**While the PR is open** (and each time it is updated or relabelled) it checks that:
* the PR is from `development` or a `hotfix/*` branch into `main`;
* the version is valid (`X.Y.Z`, optionally with a suffix such as `-rc`) and later than the previous release for the stage, production releases do not have major version 0, and the first production release is `1.0.0`;
* the build number, if the tag includes one, is greater than every build number used so far;
* the tag is not already in use.

If the checks pass, the job summary says what the release will be tagged as. If they fail, the error says why; fix the PR (e.g. by editing its title, see [Specifying the version](#specifying-the-version)) and the check runs again.

**When the PR is merged** it creates a draft release; see [What happens after merging](#what-happens-after-merging).

Each release is tagged `STAGE_vX.Y.Z` (e.g. `UAT_v1.0.2`) by default; the format can be changed, e.g. to add a build number. See [Release tag and title](#release-tag-and-title).

Example:
```yml
name: Release
on:
  pull_request:
    types: [opened, synchronize, reopened, edited, labeled, unlabeled, closed]
    branches: [main]
permissions: {}
concurrency:
  group: release-${{ github.event.pull_request.merged && 'publish' || github.event.pull_request.number }}
  cancel-in-progress: false
jobs:
  release:
    name: Release check
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: UoMResearchIT/actions/draft-release@main
        id: release
        with:
          stage: UAT
          # Optional; without this, the version comes from the PR title (e.g. "Release v1.0.2")
          # version-file: pyproject.toml
      - run: echo "Tag is $TAG"
        env:
          TAG: ${{ steps.release.outputs.tag }}
```

The `concurrency` group stops two merged releases being given the same version or build number.

## Specifying the version

The version is taken from the first of these that applies:

1. **The `version` input**, if set in the workflow.
2. **The `version-file` input**, if set: the version is read from that file in the PR (see below). Use this if your software already records its version, so that it is only written down in one place.
3. **The PR title**, if it contains `v` followed by the version, e.g. `Release v1.0.2` or `Release v2.0.0-rc`. This is the recommended way for projects that do not keep a version in a file: reviewers can see the version they are approving, it ends up in the merge commit message, and editing the title re-runs the check.
4. **The PR's labels**: the previous version for the stage is bumped, by its major number if the PR has the `release:major` label, by its minor number with `release:minor`, and otherwise by its fix number. If there is no earlier release for the stage, `1.0.0` is used for production and `0.1.0` otherwise.

Whichever is used, the check fails if:
* the version is not of the form `X.Y.Z` or `X.Y.Z-suffix`;
* the title has something that looks like a version but is not one (e.g. `Release v1.0`);
* the title has a version that differs from the one in the `version` input or `version-file` (so they cannot drift apart);
* the version is not later than the previous release of the same stage. As in [semantic versioning](https://semver.org/), `1.0.0-rc` is earlier than `1.0.0`, so a release candidate can be followed by the real release.

Different stages are counted separately, so `UAT_v1.0.2` can be followed by `prod_v1.0.2`. With labels, the release after a release candidate such as `1.0.2-rc` is `1.0.2`.

### Version files

The type of file is worked out from its name:

| File | Where the version is read from |
|---|---|
| `package.json` | the top-level `"version"` |
| `pyproject.toml` | `version = "..."` in the `[project]` or `[tool.poetry]` table |
| `*.csproj`, `*.vbproj`, `*.fsproj`, `*.props`, `*.targets` | the first `<Version>` element |
| anything else, e.g. `VERSION` | the whole file, without surrounding whitespace |

A leading `v` is ignored. While the PR is open the file is read from the PR's branch; after merging, from the merge commit.

## Release tag and title

Each release has a **tag**, which marks the merge commit in git, and a **title**, which is what people see on the Releases page.

### Tag

The tag is set by the `tag-format` input, in which these placeholders are replaced:

| Placeholder | Replaced by | Example |
|---|---|---|
| `{stage}` | the `stage` input | `UAT` |
| `{version}` (required) | the version; see [Specifying the version](#specifying-the-version) | `1.0.2` |
| `{build}` | the build number (see below) | `20` |

Some formats:

| `tag-format` | Example tag | Use when |
|---|---|---|
| `{stage}_v{version}` (default) | `UAT_v1.0.2` | Releases go through stages such as `demo`, `UAT` and `prod` |
| `v{version}` | `v1.0.2` | There is only one kind of release |
| `{stage}_v{version}_build{build}` | `UAT_v1.0.2_build20` | Each release also needs a build number, e.g. to match other build systems |

Earlier releases are found by matching their tags against the format, so it is best to choose a format at the start and keep it: releases tagged in another format are not counted when checking that versions and build numbers increase. Include `{stage}` if the same version is released to more than one stage, as otherwise the second release's tag would already be in use.

If the format includes `{build}`, the build number is one more than the highest build number in any existing tag or release (including drafts), across all stages, so build numbers always increase. Alternatively give the `build-number` input, e.g. if builds are numbered by another system; it is checked to be higher than every earlier build number.

### Title

The title is set by the `release-name` input. By default it is e.g. `UAT v1.0.2`, or `UAT v1.0.2 (build 20)` if the tag includes a build number. These placeholders can be used in it:

| Placeholder | Replaced by | Example |
|---|---|---|
| `{stage}` | the stage | `UAT` |
| `{version}` | the version | `1.0.2` |
| `{build}` | the build number, if the tag includes one | `20` |
| `{tag}` | the whole tag | `UAT_v1.0.2` |
| `{pr}` | the release PR's number | `42` |
| `{title}` | the release PR's title | `Release v1.0.2: new export formats` |

For example, `release-name: "My App {version} for user acceptance testing"` gives `My App 1.0.2 for user acceptance testing`. The title can also be edited by hand on the draft before publishing it.

## What happens after merging

When a PR into `main` is merged, the workflow runs once more, and the action:

1. checks that the PR came from one of the `source-branches`;
2. checks that the PR was merged with a merge commit, and fails if it was squashed or rebased;
3. works out the version (and build number, if used) again, and repeats the checks on them; the build number may be higher than the open PR's check said if another release happened in the meantime;
4. creates a **draft** release on GitHub with:
   * a tag such as `UAT_v1.0.2`, targeting the merge commit, and a title such as `UAT v1.0.2` (see [Release tag and title](#release-tag-and-title));
   * release notes generated by GitHub from the PRs merged since the previous release;
   * the pre-release flag set if the stage is not production, the major version is 0, or the version has a suffix such as `-rc`.

The draft is only visible to people with write access to the repository. **Nothing is tagged yet.** Someone then:

5. opens the draft from the repository's Releases page, reads through and edits the release notes if needed, and clicks **Publish release**. Publishing creates the tag on the merge commit and makes the release public.

If the PR was closed without being merged, the action does nothing.

If any check fails after merging (in practice only if the PR was squashed or rebased, or another release changed things in the meantime), no release is created and the run fails with the reason. The merge itself cannot be undone by the action, so create the release by hand in that case.

Set the `draft` input to `false` to skip step 5 and publish the release (and create the tag) straight away.

## Attaching build artifacts

This action does not upload files to the release. To attach build outputs (installers, packages, etc.) to the draft, add a job that runs after the merge, builds from the merge commit, and uploads the files with the [GitHub CLI](https://cli.github.com/manual/gh_release_upload), which is installed on GitHub-hosted runners. Add this job to the example workflow above:

```yml
  artifacts:
    needs: release
    # Only after merging; while the PR is open there is no release to attach to
    if: github.event.pull_request.merged
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          ref: ${{ github.event.pull_request.merge_commit_sha }}
          persist-credentials: false
      - name: Build
        run: make dist  # Replace with your build; put the outputs in dist/
      - name: Attach files to the draft release
        run: gh release upload "$TAG" dist/* --clobber
        env:
          GH_TOKEN: ${{ github.token }}
          GH_REPO: ${{ github.repository }}
          TAG: ${{ needs.release.outputs.tag }}
```

For `needs.release.outputs.tag` to work, the `release` job must pass on the action's output:

```yml
  release:
    name: Release check
    # ...as above...
    outputs:
      tag: ${{ steps.release.outputs.tag }}
```

Notes:
* `gh release upload` finds the draft by the tag it will have when published, and only adds files to it; the name, release notes, and draft and pre-release flags set by this action are not changed.
* `--clobber` replaces files of the same name, so the job can be re-run.
* The files are built from the merge commit, so they match exactly what the tag will point at.
* Publish the draft only once this job has finished, or the release will be published without its files.

## Blocking merges that fail the checks

For the checks to block merging, add a ruleset (or branch protection rule) on `main` that:
* **requires the `Release check` status check to pass**, so a PR cannot be merged while the check is failing; and
* **only allows the "Merge" merge method** (in the "Require a pull request before merging" rule, under "Allowed merge methods"), because the merge method cannot be checked until after the merge has happened.

Alternatively, untick "Allow squash merging" and "Allow rebase merging" in the repository settings.

With the status check required, every PR into `main` must come from one of the `source-branches`. Urgent fixes should be made on a `hotfix/...` branch taken from `main`: the PR gets the same checks, and merging it makes a release (a fix-number bump by default). Afterwards, merge `main` back into `development` so that the fix is not lost from the next release.

## Inputs
* `stage` (default `prod`)

  The tag prefix describing the release stage, e.g. `demo`, `UAT` or `prod`.

* `production-stage` (default `prod`)

  Which stage counts as production. Releases of other stages, and releases with a major version of 0 or a version suffix, are marked as pre-releases. The check fails if a production release has major version 0, or if the first production release is not `1.0.0`.

* `version` (optional)

  The version to release, e.g. `1.0.2` or `1.0.0-rc`. If omitted, it comes from `version-file`, the PR title, or the PR's labels; see [Specifying the version](#specifying-the-version).

* `version-file` (optional)

  A file in the repository to read the version from, e.g. `pyproject.toml`; see [Version files](#version-files).

* `tag-format` (default `{stage}_v{version}`)

  The format of the release's tag; see [Tag](#tag).

* `build-number` (optional)

  The build number, if `tag-format` includes `{build}`. Give this if your builds are numbered elsewhere (e.g. by CI builds that are not released); it must be higher than every build number already in a tag or release. It is an error to give it if `tag-format` does not include `{build}`.

* `source-branches` (default `development hotfix/*`)

  The branches the PR may come from, separated by spaces or newlines. `*` matches any characters, so `hotfix/*` allows `hotfix/login-crash`. Set to an empty string to allow any branch.

* `target-branch` (default `main`)

  The branch the PR must be merged into.

* `release-name` (optional)

  The title of the release; see [Title](#title).

* `draft` (default `true`)

  Whether to create a draft release. If `false`, the release is published immediately and the tag is created straight away.

* `token` (default `${{ github.token }}`)

  The token to use.

## Outputs
* `tag`

  The release's tag, e.g. `prod_v1.0.2`.

* `version`

  The version, e.g. `1.0.2`.

* `build-number`

  The build number, e.g. `24`, or empty if `tag-format` does not include `{build}`.

* `release-url`

  The URL of the release, or empty if the PR has not been merged yet.

## Permissions
Requires: `contents: write`.
