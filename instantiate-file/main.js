const { appendFileSync, writeFileSync, unlinkSync, mkdtempSync } = require("fs");
const { EOL } = require("os");
const { join } = require("path");

/**
 * Create a file based on inputs.
 * @param {string} key Unique key.
 */
function mainStep(key) {
    const value = process.env.INPUT_VALUE;
    const b64 = process.env.INPUT_BASE64;
    let filename = process.env.INPUT_FILENAME;
    if (filename === undefined || filename == "") {
        const d = mkdtempSync("instantiate-");
        filename = join(d, "datum");
    }
    if (b64 == 'true') {
        const decoded = new Buffer(value, "base64");
        writeFileSync(filename, decoded);
    } else {
        writeFileSync(filename, value);
    }
    appendFileSync(process.env.GITHUB_STATE, `${key}=${filename}${EOL}`);
    appendFileSync(process.env.GITHUB_OUTPUT, `filename=${filename}${EOL}`);
    process.stdout.write(`created ${filename}${EOL}`);
}

/**
 * Delete the file created by {@link mainStep()}.
 * @param {string} key Unique key.
 */
function postStep(key) {
    const filename = process.env[`STATE_${key}`];
    unlinkSync(filename);
    process.stdout.write(`deleted ${filename}${EOL}`);
}

const key = process.env.INPUT_KEY.toUpperCase();
if (process.env[`STATE_${key}`] === undefined) {
    mainStep(key);
} else {
    postStep(key);
}
