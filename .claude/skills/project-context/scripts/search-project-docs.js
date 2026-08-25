#!/usr/bin/env node
// Search project docs under docs/<project>/ by keyword.
// Usage: node search-project-docs.js <project> [keyword] [--case-sensitive] [--fuzzy]
const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
const flags = new Set(args.filter(a => a.startsWith('--')));
const positional = args.filter(a => !a.startsWith('--'));

const [project, keyword] = positional;
const caseSensitive = flags.has('--case-sensitive');
const fuzzy = flags.has('--fuzzy');

if (!project) {
  console.error('Usage: search-project-docs.js <project> [keyword] [--case-sensitive] [--fuzzy]');
  process.exit(1);
}

const root = path.resolve(__dirname, '../../../..');
const docsDir = path.join(root, 'docs', project);

if (!fs.existsSync(docsDir)) {
  console.error(`Project folder not found: docs/${project}`);
  console.error(`Available projects: ${fs.readdirSync(path.join(root, 'docs')).join(', ')}`);
  process.exit(1);
}

const files = fs.readdirSync(docsDir)
  .filter(f => f.endsWith('.md'))
  .map(f => path.join(docsDir, f));

// Fuzzy match: every character in the term must appear in order in the target.
function fuzzyMatch(target, term) {
  let ti = 0;
  for (let i = 0; i < target.length && ti < term.length; i++) {
    if (target[i] === term[ti]) ti++;
  }
  return ti === term.length;
}

function matches(text, term) {
  const t = caseSensitive ? text : text.toLowerCase();
  const k = caseSensitive ? term : term.toLowerCase();
  return fuzzy ? fuzzyMatch(t, k) : t.includes(k);
}

const term = keyword || null;
const results = [];

for (const file of files) {
  const name = path.basename(file);
  const content = fs.readFileSync(file, 'utf8');

  if (!term) {
    results.push({ file: path.relative(root, file), excerpt: content.split('\n')[0] });
    continue;
  }

  const nameMatch = matches(name, term);
  const lines = content.split('\n');
  const matchLine = lines.findIndex(l => matches(l, term));

  if (nameMatch || matchLine !== -1) {
    const start = Math.max(0, matchLine === -1 ? 0 : matchLine - 1);
    const excerpt = lines.slice(start, start + 3).join('\n');
    results.push({ file: path.relative(root, file), excerpt });
  }
}

if (results.length === 0) {
  console.log(`No matches for "${keyword}" in docs/${project}/`);
  process.exit(0);
}

const modeLabel = [fuzzy && 'fuzzy', caseSensitive && 'case-sensitive'].filter(Boolean).join(', ');
console.log(`Found ${results.length} file(s) in docs/${project}/${term ? ` matching "${keyword}"${modeLabel ? ` (${modeLabel})` : ''}` : ''}:\n`);
for (const { file, excerpt } of results) {
  console.log(`--- ${file}`);
  console.log(excerpt);
  console.log();
}
