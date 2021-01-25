'use strict';

const { Octokit } = require("@octokit/rest");

const sodium = require('tweetsodium');
const key = "base64-encoded-public-key";

const octokit = new Octokit({
    auth: process.env.PA_TOKEN
});

const fs = require('fs');

let rawData = fs.readFileSync('secrets.json');
let secrets = JSON.parse(rawData);

for (let key in secrets) {
    if (secrets.hasOwnProperty(key)){
        console.log(key);
        console.log(secrets[key]);
    }
}

// await octokit.request('PUT /repos/{owner}/{repo}/actions/secrets/{secret_name}', {
//     owner: 'octocat',
//     repo: 'hello-world',
//     secret_name: 'secret_name',
//     encrypted_value: 'encrypted_value'
// });