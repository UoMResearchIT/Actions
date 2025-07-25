# UoM Research IT Github Actions
This is a collection of Github Actions, mainly for University of Manchester use. We do not intend to publish these to the Github Actions Marketplace.

# General Tools

These are intended for use in many types of project, wherever relevant.

## Multi-platform

* [`commit-id`](commit-id) helps generate a file containing the ID of the commit within it. 

* [`compare-output`](compare-output) compares the output of a program to a string. Great for testing!

* [`download`](download) does cached downloads of files from the web.

* [`instantiate-file`](instantiate-file) creates a file with a value provided by your workflow.

* ['add_prs_to_project (reusable workflow)](.github/workflows/add_prs_to_project.yml) is a reusable workflow that you can use in your repository to add any PRs assigned to a user to a Project and set the Status in the project to a value of your choosing.

## Linux runners only

* [`apt-get-install`](apt-get-install) installs packages into Ubuntu runners, allowing for subtleties of installation that have been found to come up with some packages "in the wild".

* [`docker-publish-to-ghcr`](docker-publish-to-ghcr) publishes a workflow-local Docker image to the Github container registry.

* [`check-copyrights`](check-copyrights) ensures that all files in your repository have an "acceptable" copyright notice near their top.

* [`todo`](todo) finds `FIXME` and `TODO` comments in code.

# Language-Specific Tools

These often have platform requirements for their runners. You can always have several jobs in a workflow to allow the use of Linux runners in an otherwise Windows-specific build scheme.

## C and C++

* [`doxygen-to-pages`](doxygen-to-pages) runs [Doxygen](https://doxygen.nl/) to generate a simple deployable documentation site.

* [`run-c-style-check`](run-c-style-check) runs a [simple style checker](https://github.com/verateam/vera) against your C or C++ code.

* [`run-clang-tidy`](run-clang-tidy) does static analysis of C or C++ codebases with [`clang-tidy`](https://clang.llvm.org/extra/clang-tidy/) to find likely problems.

## C#

* [`configure-nuget-for-github`](configure-nuget-for-github) sets up NuGet to access GitHub packages.

## Python

* [`python-import-all-test`](python-import-all-test) runs a simple test to import all the Python files beneath a particular module.

* [`run-pylint`](run-pylint) runs the Python code style checker [`pylint`](https://github.com/pylint-dev/pylint) over some code. It includes support for spell-checking documentation strings.

# Special-Use Tools

These are intended to support particular other repositories and working practices. They may be non-applicable more widely.

* [`check-ruleset-containment`](check-ruleset-containment) checks whether a ruleset minimally conforms to another ruleset.

* [`get-repo-ruleset`](get-repo-ruleset) gets the ruleset applied to a particular branch of a repository.

* [`reuse`](reuse) checks that the licenses of all files conform to the REUSE standard.
