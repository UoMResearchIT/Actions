# Create Release

Tags a commit and creates a GitHub release for it, then closes the release's milestone.
The release notes list the pull requests merged since the previous release, as GitHub's "Generate release notes" button does.
The version is read from a file in your repository, so bumping it is the only manual step.

Use this when merging into a branch is your release, e.g. merging `dev` into `main` (or `release`) in Gitflow, to replace drafting the release by hand afterwards.
Hotfixes merged into the same branch are released the same way.

In `check` mode it creates nothing; run on the release pull request, it fails if the version has already been released or is not newer than the latest release, so a forgotten version bump is caught before merging.

```yml
on:
  push:
    branches: [main]
permissions:
  contents: write
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: UoMResearchIT/actions/create-release@main
        with:
          version-file: VERSION
```

This releases the version in the file `VERSION` (e.g. `1.2.3`) as the tag `v1.2.3`, unless that tag already exists.

Any runner will do, and the repository does not need to be checked out: the version file is read through the GitHub API, at the commit being released.

## What it does

1. Reads the version from `version`, or from `version-file` at the target commit, using `version-pattern` to find it in the file. A leading `v` is dropped.
2. Finds the earlier releases: the existing tags of the form given by `tag`. Those that do not hold a version are ignored.
3. If the tag already exists, stops: in `release` mode it succeeds without releasing (or fails, with `if-exists: fail`); in `check` mode it fails.
4. Fails if the version is not newer than the latest release, unless `require-increase` is `false`.
5. Warns if the `milestone` still has open issues or pull requests. On a pull request, the pull request itself does not count. A missing milestone is only warned about in `check` mode, when it can still be fixed before merging; in `release` mode it is just logged, as releases such as hotfixes often have no milestone.
6. In `check` mode, stops here.
7. Generates release notes from the previous release, i.e. the newest earlier release with a lower version, and creates the release and its tag on the target commit.
8. Closes the milestone, if it has no open issues or pull requests left.

Versions are numbers separated by dots, with any number of parts (`1.2`, `1.2.3`, `1.2.3.4`) and optionally a pre-release label (`2.0.0-rc.1`), compared part by part.

## Example: a Gitflow project

This is the release process of a project that releases by merging `dev` into a `release` branch, with its version in `appsettings.json`, tags like `Release_v1.14.2` and a milestone per release, like `v1.14.2`.

On the release pull request, check that the version was bumped:

```yml
name: Check release
on:
  pull_request:
    branches: [release]
permissions: {}
jobs:
  check:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      issues: read
    steps:
      - uses: UoMResearchIT/actions/create-release@main
        with:
          mode: check
          version-file: MyApp/appsettings.json
          version-pattern: '"VersionNumber"\s*:\s*"([^"]+)"'
          tag: Release_v{version}
          milestone: v{version}
```

Make this a required status check on `release` to stop merges until it passes.

Once merged, release it:

```yml
name: Release
on:
  push:
    branches: [release]
permissions: {}
concurrency:
  group: release
  cancel-in-progress: false
jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      issues: write
    steps:
      - uses: UoMResearchIT/actions/create-release@main
        id: release
        with:
          version-file: MyApp/appsettings.json
          version-pattern: '"VersionNumber"\s*:\s*"([^"]+)"'
          tag: Release_v{version}
          title: v{version}
          milestone: v{version}
      - if: steps.release.outputs.created == 'true'
        run: echo "Released $URL"
        env:
          URL: ${{ steps.release.outputs.release-url }}
```

A hotfix bumps the version, e.g. to `1.14.2.1` or `1.14.3`, and is merged into `release` in the same way.

## Inputs

* `mode`

  `release` (the default) to create the release, or `check` to only check that the version can be released.

* `version`

  The version to release, e.g. `1.2.3`. If empty, it is read from `version-file`.

* `version-file`

  The file holding the version, relative to the repository root, read at the target commit.

* `version-pattern`

  A JavaScript regular expression that finds the version in `version-file`. Its first group, or the whole match if it has no group, is the version. If empty (the default), the whole file, less surrounding whitespace, is the version. Some examples:

  | File | Pattern |
  |---|---|
  | `appsettings.json` | `"VersionNumber"\s*:\s*"([^"]+)"` |
  | `package.json` | `"version"\s*:\s*"([^"]+)"` |
  | `pyproject.toml` | `^version\s*=\s*"([^"]+)"` |
  | `*.csproj` | `<Version>([^<]+)</Version>` |

* `tag`

  The tag name, with `{version}` where the version goes. Default: `v{version}`. Existing tags of this form are taken to be the earlier releases, so keep it the same as your existing tags.

* `title`

  The release title, with `{version}` where the version goes. Defaults to the tag name.

* `milestone`

  The milestone to close after releasing, with `{version}` where the version goes, e.g. `v{version}`. If it still has open issues or pull requests, it is left open with a warning. If empty (the default), milestones are not touched.

* `target`

  The commit (SHA or branch name) to release. Defaults to the commit that triggered the workflow.

* `if-exists`

  What `release` mode does if the tag already exists: `skip` (the default) succeeds without releasing, so pushes that do not bump the version are harmless; `fail` fails.

* `require-increase`

  If `true` (the default), fail if the version is not newer than the latest release. Set to `false` to release an older line, e.g. a hotfix to 1.2 after 1.3 is out; consider `latest: false` too.

* `draft`

  If `true`, create the release as a draft, to be published by hand. Default: `false`. The tag is only created when the draft is published, so re-running before then creates another draft.

* `prerelease`

  If `true`, mark the release as a pre-release, which is never the latest release. Default: `false`.

* `latest`

  Whether the release becomes the repository's latest release: `true` (the default), `false`, or `legacy` (decided by creation date and version).

* `token`

  The token used to call the GitHub API. Default: the workflow's `GITHUB_TOKEN`.

## Outputs

* `version`

  The version, without any leading `v`.

* `tag`

  The tag name.

* `previous-tag`

  The tag of the release before this one, or empty if this is the first.

* `created`

  `true` if a release was created, otherwise `false`.

* `release-url`

  The release's web page, if one was created.

## Permissions

For `release` mode: `contents: write`, and `issues: write` if `milestone` is given.

For `check` mode: `contents: read`, and `issues: read` if `milestone` is given.

> [!NOTE]
> Tags and releases created with the workflow's `GITHUB_TOKEN` do not trigger other workflows, e.g. ones that run `on: release`.
> If you need them to, pass a GitHub App token as `token`.
>
> If a ruleset restricts creating tags, the token's identity must be allowed to bypass it.

## Release notes

The notes are GitHub's generated release notes: a list of the pull requests merged since the previous release, with their authors, and a link to the full changelog.
To group them by label or leave some out, add a [`.github/release.yml`](https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes#configuring-automatically-generated-release-notes) to your repository.
