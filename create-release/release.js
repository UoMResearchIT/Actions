// Copyright (c) 2026 The University of Manchester
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

"use strict";

const PLACEHOLDER = "{version}";

/**
 * Parse a version such as 1.2.3, 1.13.6.1 or 2.0.0-rc.1.
 * @param {string} text The version, without any tag prefix.
 * @returns {{parts: number[], pre: string} | null} null if not a version.
 */
function parseVersion(text) {
    const m = /^(\d+(?:\.\d+)*)(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?$/.exec(text);
    if (!m) {
        return null;
    }
    return { parts: m[1].split(".").map(Number), pre: m[2] ?? "" };
}

/**
 * Compare two parsed versions. Missing numeric parts count as 0, so 1.2 equals
 * 1.2.0. A pre-release sorts before the same version without one; two
 * pre-release labels are compared as text.
 * @returns {number} negative, zero or positive, as for Array.prototype.sort.
 */
function compareVersions(a, b) {
    const n = Math.max(a.parts.length, b.parts.length);
    for (let i = 0; i < n; i++) {
        const d = (a.parts[i] ?? 0) - (b.parts[i] ?? 0);
        if (d !== 0) {
            return Math.sign(d);
        }
    }
    if (a.pre === b.pre) {
        return 0;
    }
    if (a.pre === "") {
        return 1;
    }
    if (b.pre === "") {
        return -1;
    }
    return a.pre < b.pre ? -1 : 1;
}

/**
 * Get the version from a file's contents.
 * @param {string} content The file's contents.
 * @param {string} pattern A regular expression; its first group (or the whole
 *     match if it has none) is the version. If empty, the whole file is used.
 */
function extractVersion(content, pattern) {
    if (!pattern) {
        return content.trim();
    }
    const m = new RegExp(pattern, "m").exec(content);
    if (!m) {
        throw new Error(`version-pattern ${pattern} does not match the version file`);
    }
    return (m[1] ?? m[0]).trim();
}

/**
 * Split a template such as Release_v{version} around its placeholder.
 * @returns {{prefix: string, suffix: string}}
 */
function splitTemplate(name, template) {
    const at = template.indexOf(PLACEHOLDER);
    if (at < 0 || template.indexOf(PLACEHOLDER, at + 1) >= 0) {
        throw new Error(`${name} must contain ${PLACEHOLDER} exactly once: ${template}`);
    }
    return { prefix: template.slice(0, at), suffix: template.slice(at + PLACEHOLDER.length) };
}

function fill(template, version) {
    return template.replaceAll(PLACEHOLDER, version);
}

/**
 * Find the existing tags that follow the tag template, with their versions.
 * Tags that follow the template but do not hold a version are ignored.
 */
async function listVersionTags(github, owner, repo, tagTemplate) {
    const { prefix, suffix } = splitTemplate("tag", tagTemplate);
    const refs = await github.paginate(github.rest.git.listMatchingRefs, {
        owner,
        repo,
        ref: `tags/${prefix}`,
        per_page: 100,
    });
    const tags = [];
    for (const { ref } of refs) {
        const name = ref.slice("refs/tags/".length);
        if (!name.startsWith(prefix) || !name.endsWith(suffix)) {
            continue;
        }
        const version = parseVersion(name.slice(prefix.length, name.length - suffix.length));
        if (version) {
            tags.push({ name, version });
        }
    }
    return tags;
}

async function readVersion(github, owner, repo, ref, file, pattern) {
    let data;
    try {
        ({ data } = await github.rest.repos.getContent({
            owner,
            repo,
            path: file,
            ref,
            mediaType: { format: "raw" },
        }));
    } catch (e) {
        throw new Error(`Cannot read version-file ${file} at ${ref}: ${e.message}`);
    }
    if (typeof data !== "string") {
        throw new Error(`version-file ${file} is not a file`);
    }
    return extractVersion(data, pattern);
}

async function findMilestone(github, owner, repo, title) {
    const milestones = await github.paginate(github.rest.issues.listMilestones, {
        owner,
        repo,
        state: "open",
        per_page: 100,
    });
    return milestones.find((m) => m.title === title);
}

/**
 * Entry point, called from actions/github-script. Inputs come from RELEASE_*
 * environment variables set by action.yml.
 */
async function main({ github, context, core }) {
    const env = process.env;
    const flag = (name) => env[name] === "true";
    const mode = env.RELEASE_MODE || "release";
    const ifExists = env.RELEASE_IF_EXISTS || "skip";
    if (!["release", "check"].includes(mode)) {
        throw new Error(`mode must be release or check, not ${mode}`);
    }
    if (!["skip", "fail"].includes(ifExists)) {
        throw new Error(`if-exists must be skip or fail, not ${ifExists}`);
    }
    const { owner, repo } = context.repo;
    const target = env.RELEASE_TARGET || context.sha;
    const tagTemplate = env.RELEASE_TAG || `v${PLACEHOLDER}`;
    splitTemplate("tag", tagTemplate);

    // Which version?
    let version = env.RELEASE_VERSION?.trim() ?? "";
    if (!version) {
        if (!env.RELEASE_VERSION_FILE) {
            throw new Error("Give either version or version-file");
        }
        version = await readVersion(github, owner, repo, target,
            env.RELEASE_VERSION_FILE, env.RELEASE_VERSION_PATTERN);
    }
    version = version.replace(/^[vV]/, "");
    const parsed = parseVersion(version);
    if (!parsed) {
        throw new Error(`"${version}" is not a version such as 1.2.3`);
    }
    const tag = fill(tagTemplate, version);
    core.setOutput("version", version);
    core.setOutput("tag", tag);
    core.setOutput("created", "false");
    core.info(`Version ${version}, tag ${tag}, commit ${target}`);

    // How does it compare with earlier releases?
    const tags = await listVersionTags(github, owner, repo, tagTemplate);
    tags.sort((a, b) => compareVersions(a.version, b.version));
    const latest = tags.at(-1);
    const previous = tags.filter((t) => compareVersions(t.version, parsed) < 0).at(-1);
    core.setOutput("previous-tag", previous?.name ?? "");

    if (tags.some((t) => t.name === tag)) {
        if (mode === "check") {
            core.setFailed(`Tag ${tag} already exists, so version ${version} has already been released. Bump the version.`);
        } else if (ifExists === "fail") {
            core.setFailed(`Tag ${tag} already exists.`);
        } else {
            core.notice(`Tag ${tag} already exists, so no release was created.`);
        }
        return;
    }
    if (flag("RELEASE_REQUIRE_INCREASE") && latest && compareVersions(parsed, latest.version) <= 0) {
        core.setFailed(`Version ${version} is not newer than the latest release, ${latest.name}. Bump the version, or set require-increase to false.`);
        return;
    }

    // Is the milestone finished?
    const milestoneTitle = env.RELEASE_MILESTONE ? fill(env.RELEASE_MILESTONE, version) : "";
    let milestone;
    let openItems = 0;
    if (milestoneTitle) {
        milestone = await findMilestone(github, owner, repo, milestoneTitle);
        if (!milestone) {
            // Before merging, a missing milestone (e.g. a misspelt one) can
            // still be fixed, so warn. After merging it can't, and releases
            // such as hotfixes often have no milestone, so just log it.
            const message = `There is no open milestone called ${milestoneTitle}.`;
            if (mode === "check") {
                core.warning(message);
            } else {
                core.info(message);
            }
        } else {
            openItems = milestone.open_issues;
            // The release PR itself may be in the milestone; it does not count.
            const pr = context.payload.pull_request;
            if (pr?.state === "open" && pr.milestone?.number === milestone.number) {
                openItems--;
            }
            if (openItems > 0) {
                core.warning(`Milestone ${milestoneTitle} still has ${openItems} open issues or pull requests.`);
            }
        }
    }

    if (mode === "check") {
        core.notice(`Version ${version} can be released as ${tag}` +
            (previous ? `, following ${previous.name}.` : "; it is the first release."));
        return;
    }

    // Release.
    const { data: notes } = await github.rest.repos.generateReleaseNotes({
        owner,
        repo,
        tag_name: tag,
        target_commitish: target,
        ...(previous && { previous_tag_name: previous.name }),
    });
    const prerelease = flag("RELEASE_PRERELEASE");
    const { data: release } = await github.rest.repos.createRelease({
        owner,
        repo,
        tag_name: tag,
        target_commitish: target,
        name: fill(env.RELEASE_TITLE || tagTemplate, version),
        body: notes.body,
        draft: flag("RELEASE_DRAFT"),
        prerelease,
        make_latest: prerelease ? "false" : (env.RELEASE_LATEST || "true"),
    });
    core.setOutput("created", "true");
    core.setOutput("release-url", release.html_url);
    core.notice(`Created release ${release.name}: ${release.html_url}`);

    if (milestone && openItems === 0) {
        await github.rest.issues.updateMilestone({
            owner,
            repo,
            milestone_number: milestone.number,
            state: "closed",
        });
        core.info(`Closed milestone ${milestoneTitle}.`);
    } else if (milestone) {
        core.warning(`Milestone ${milestoneTitle} was left open, as it still has open issues or pull requests.`);
    }
}

module.exports = main;
module.exports.parseVersion = parseVersion;
module.exports.compareVersions = compareVersions;
module.exports.extractVersion = extractVersion;
module.exports.splitTemplate = splitTemplate;
