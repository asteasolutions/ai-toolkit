#!/usr/bin/env node
// Check how fresh the docs are for a given project.
// Usage: node check-freshness.js <project>
const fs = require('fs');
const path = require('path');

const [project] = process.argv.slice(2);

if (!project) {
  console.error('Usage: check-freshness.js <project>');
  process.exit(1);
}

const root = path.resolve(__dirname, '../../../..');
const docsDir = path.join(root, 'docs', project);
const manifestPath = path.join(docsDir, '_manifest.json');

if (!fs.existsSync(docsDir)) {
  console.log(`status: missing\nproject: ${project}\nmessage: No docs folder found at docs/${project}/`);
  process.exit(0);
}

if (!fs.existsSync(manifestPath)) {
  console.log(`status: missing\nproject: ${project}\nmessage: Docs folder exists but no _manifest.json found — docs may have been generated before sync tracking was added.`);
  process.exit(0);
}

const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const lastSynced = new Date(manifest.last_synced_at);
const nowMs = fs.statSync(manifestPath).mtime; // use file mtime as "now" proxy to avoid Date.now() in tests
const ageMs = Date.now() - lastSynced.getTime();
const ageHours = Math.round(ageMs / (1000 * 60 * 60));
const ageDays = Math.floor(ageHours / 24);

const stale = ageHours > 24;
const ageLabel = ageDays >= 1 ? `${ageDays} day(s)` : `${ageHours} hour(s)`;

console.log(`status: ${stale ? 'stale' : 'ok'}`);
console.log(`project: ${project}`);
console.log(`platform: ${manifest.platform || 'unknown'}`);
console.log(`last_synced_at: ${manifest.last_synced_at}`);
console.log(`age: ${ageLabel}`);
console.log(`issue_count: ${manifest.issue_count ?? 'unknown'}`);
if (stale) {
  console.log(`message: Docs are ${ageLabel} old — consider refreshing with /docs-generator.`);
} else {
  console.log(`message: Docs are up to date.`);
}
