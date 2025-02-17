# UoM Resarch IT Github Actions
This is a collection of Github Actions, mainly for University of Manchester use. It is the intention to make this into a _public_ repository once we are happy with the name, have a suitable agreed license, etc.

## `apt-get-install`

[This](apt-get-install) installs packages into Ubuntu runners, allowing for subtleties of installation that have been found to come up with some packages "in the wild".

## `check-copyrights`

[This](check-copyrights) ensures that all files in your repository have an "acceptable" copyright notice near their top.

## `commit-id`

[This](commit-id) helps generate a file containing the ID of the commit within it. 

## `compare-output`

[This](compare-output) compares the output of a program to a string. Great for testing!

## `run-c-style-check`
[This](run-c-style-check) runs a [simple style checker](https://github.com/verateam/vera) against your C or C++ code.

## `run-clang-tidy`

[This](run-clang-tidy) does static analysis of C or C++ codebases with [`clang-tidy`](https://clang.llvm.org/extra/clang-tidy/) to find likely problems.

## `run-pylint`

[This](run-pylint) runs the Python code style checker [`pylint`](https://github.com/pylint-dev/pylint) over some code. It includes support for spell-checking documentation strings.
