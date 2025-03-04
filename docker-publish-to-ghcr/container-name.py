# Copyright (c) 2025 The University of Manchester
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

import os, re

container = os.environ.get("CONTAINER", "").lower()
if container == "":
    # GITHUB_CONTAINER is a two-part name like UoMResearchIT/actions
    container = re.sub(r".*/", "", os.environ["GITHUB_REPOSITORY"]).lower()
    print(f"determined container name to be \033[0;32m{container}\033[0m")
namespace = os.environ["NAMESPACE"].lower()
version = os.environ["VERSION"]

with open(os.environ["GITHUB_OUTPUT"], "a") as f:
    f.write(f"container={container}\n")
    f.write(f"namespace={namespace}\n")
    f.write(f"handle=ghcr.io/{namespace}/{container}:{version}\n")
