# Copyright (c) 2017-2025 The University of Manchester
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import importlib
import os
import re
import sys
import traceback
from pathlib import Path
from collections.abc import Sequence


#: Matches names that are legal components of a Python identifier.
NAME_RE = re.compile("^[a-zA-Z_][a-zA-Z0-9_]*$")


def _print_note(msg: str) -> None:
    """
    Write a note to stdout.

    :param msg: the message to write
    """
    print(msg)


def _print_warning(msg: str) -> None:
    """
    Write a warning to stdout.

    :param msg: the message to write
    """
    print(f"\033[0;33m{msg}\033[0m")


def _print_error(msg: str) -> None:
    """
    Write an error to stdout.

    :param msg: the message to write
    """
    print(f"\033[0;31m{msg}\033[0m", flush=True)


def _print_good(msg: str) -> None:
    """
    Write a good message to stdout.

    :param msg: the message to write
    """
    print(f"\033[0;32m{msg}\033[0m", flush=True)


def _all_modules(directory: Path, prefix: str,
                 remove_pyc_files: bool,
                 results: set[str]) -> None:
    """
    List all the python files found in this directory giving then the prefix.

    Any file that ends in either ``.py`` or ``.pyc`` is assume a python module
    and added to the result set.

    :param directory: path to check for python files
    :param prefix: package prefix top add to the file name
    :param remove_pyc_files: whether to delete ``.pyc`` files when found
    :param results: the set to accumulate the python package names in
    """

    to_unlink: list[Path] = []
    for file in directory.iterdir():
        if file.name == "__init__.py":
            results.add(prefix)
        elif file.name == "__init__.pyc":
            results.add(prefix)
            if remove_pyc_files:  # pragma: no cover
                to_unlink.append(file)
        elif file.suffix == ".py":
            if NAME_RE.match(file.stem):
                results.add(f"{prefix}.{file.stem}")
        elif file.suffix == ".pyc":
            if NAME_RE.match(file.stem):
                results.add(f"{prefix}.{file.stem}")
            if remove_pyc_files:  # pragma: no cover
                to_unlink.append(file)
        elif file.name != "__pycache__" and NAME_RE.match(file.name) and file.is_dir:
            _all_modules(file, f"{prefix}.{file.name}", remove_pyc_files, results)
    for file in to_unlink:  # pragma: no cover
        _print_note(f"Deleting: {file}")
        file.unlink()


def _print_import_exception(module: str, exc: Exception) -> None:
    """
    Write an exception to stdout, formatted in standard form for this code.
    """
    _print_error(f"Error importing module {module}:")
    for line in (
            line for tb_msgs in traceback.format_exception(exc)
            for line in tb_msgs.splitlines()):
        _print_warning(f"  {line}")


def _load_modules(
        directory: Path, prefix: str, remove_pyc_files: bool,
        exclusions: frozenset[str]) -> int:
    """
    Loads all the python files found in this directory, giving them the
    specified prefix.

    Any file that ends in either ``.py`` or ``.pyc`` is assume a python module
    and added to the result set.

    :param directory: path to check for python files
    :param prefix: package prefix top add to the file name
    :param remove_pyc_files: True if ``.pyc`` files should be deleted
    :param exclusions: a set of modules to exclude
    :return: number of errors found
    """
    modules: set[str] = set()
    _all_modules(directory, prefix, remove_pyc_files, modules)

    errors: list[tuple[str, Exception]] = list()
    for module in modules:
        if module in exclusions:
            _print_warning(f"SKIPPING {module}")
            continue
        try:
            __import__(module)
        except Exception as e:  # pylint: disable=broad-except
            _print_error(f"Error with {module}")
            errors.append((module, e))
        else:
            _print_note(f"checked {module}")

    for module, exc in errors:
        _print_import_exception(module, exc)
    return len(errors)


def load_module(
        name: str, remove_pyc_files: bool = False,
        exclusions: Sequence[str] = ()) -> int:
    """
    Loads this module and all its children.

    :param name: name of the module
    :param remove_pyc_files: True if ``.pyc`` files should be deleted
    :param exclusions: a list of modules to exclude
    :return: suggested exit code
    """
    try:
        module = importlib.import_module(name)
    except Exception as e:
        _print_import_exception(name, e)
        return 2
    path = module.__file__
    if path is None:
        _print_error(f"cannot determine path to module {name}")
        return 2

    if _load_modules(Path(path).parent, name, remove_pyc_files,
                     frozenset(exclusions)):
        _print_error(f"Error when importing, starting at {name}")
        return 1
    else:
        _print_good(f"module {name} and descendents are importable")
        return 0


if __name__ == '__main__':
    sys.exit(load_module(
        os.environ["BASE_MODULE"],
        os.environ.get("REMOVE_PYC", "false").lower() == "true",
        map(str.strip, os.environ.get("EXCLUSIONS", "").split(","))))
