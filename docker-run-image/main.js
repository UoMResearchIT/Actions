// Copyright (c) 2025 The University of Manchester
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const { appendFileSync } = require("fs");
const { EOL } = require("os");
const { spawnSync } = require("child_process");

/** Characters that can be used for random ID generation. */
const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

/**
 * Run a docker subprocess.
 * @param {string[]} args Arguments to pass to 'docker'.
 * @return {number} The exit code.
 */
function docker(args) {
    const result = spawnSync("docker", args, {"stdio": "inherit"});
    if (result.error) {
        throw new Error(result.error);
    }
    return result.status;
}

/**
 * Launch a docker container.
 * @param {string} key Unique key.
 */
function mainStep(key) {
    const image_id = process.env.INPUT_IMAGE_ID;
    const port = process.env.INPUT_PORT;
    const run_args = process.env.INPUT_RUN_ARGS;

    if (image_id === undefined || image_id == "") {
        console.log(process.env); // DEBUG
        throw new Error("no image-id provided");
    }

    // Define a random container ID
    let container = "docker-run-image-";
    for (let i = 0; i < 12; i++) {
        container += characters.charAt(Math.floor(Math.random() * characters.length));
    }

    appendFileSync(process.env.GITHUB_STATE, `${key}=${container}${EOL}`);
    appendFileSync(process.env.GITHUB_OUTPUT, `container-id=${container}${EOL}`);

    // Build the command to run in an array
    let args = ["run", "-d", "--name", container];
    if (port !== undefined) {
        args.push("-p", `${port}:${port}`);
    }
    if (run_args !== undefined) {
        let myRegexp = /[^\s"]+|"([^"]*)"/g;
        do {
            // Each call to exec returns the next regex match as an array
            var match = myRegexp.exec(run_args);
            if (match != null)
                args.push(match[1] ? match[1] : match[0]);
        } while (match != null);
    }
    args.push(image_id);

    console.log(`about to run 'docker ${args}'`);

    // Call 'docker run'...
    process.exit(docker(args));
}

/**
 * Shut down the docker container created by {@link mainStep()}.
 * @param {string} key Unique key.
 */
function postStep(key) {
    const container = process.env[`STATE_${key}`];
    if (container === undefined) {
        throw new Error("missing container ID");
    }

    // Call 'docker rm'...
    docker(["rm", "-f", container]);
    // Ignore the exit code
}

const key = process.env.GITHUB_ACTION.toUpperCase();
if (process.env[`STATE_${key}`] === undefined) {
    mainStep(key);
} else {
    postStep(key);
}
