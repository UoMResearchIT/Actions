#!/usr/bin/env bash

# Copyright (c) 2020 The University of Manchester
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

cd "$GITHUB_ACTION_PATH" || exit 2

dir=apache-rat-${RAT_VERSION}
raturl="${RAT_MIRROR}creadur/$dir/$dir-bin.tar.gz"

if [ -d $dir ]; then
    echo "::debug::Already downloaded; skipping..."
    exit 0
fi

curl --retry 5 -I -L -D - "$raturl" |& tee -a curl_out.log | grep -q "^HTTP.*200.*$" || {
    echo "::error title=Download Failed::Version of RAT ($RAT_VERSION) is wrong or mirror is down (URL: $raturl)"
    cat curl_out.log
    exit 1
}

curl --retry 5 -s -L --output - "$raturl" | tar -zxf -
exit $?
