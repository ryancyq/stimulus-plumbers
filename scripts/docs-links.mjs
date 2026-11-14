// Fails when a relative markdown link, or its #anchor, does not resolve.
// Checks every tracked docs/ page, README.md, CLAUDE.md, and ARIA.md.
import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync, statSync } from 'node:fs';
import { dirname, join } from 'node:path';

const PATTERNS = ['*/docs/**/*.md', '**/README.md', '**/CLAUDE.md', 'ARIA.md'];
const LINK = /\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g;
const EXTERNAL = /^(?:[a-z][a-z0-9+.-]*:|\/\/)/i;

const documents = execFileSync('git', ['ls-files', '-z', '--', ...PATTERNS.map((p) => `:(glob)${p}`)], {
  encoding: 'utf8',
})
  .split('\0')
  .filter(Boolean);

// Lines outside fenced code blocks; inline code is dropped except in headings, where it names the anchor.
function prose(text) {
  const lines = [];
  let fenced = false;
  for (const line of text.split('\n')) {
    if (/^\s*(```|~~~)/.test(line)) fenced = !fenced;
    else if (!fenced) lines.push(/^#/.test(line) ? line : line.replace(/`[^`]*`/g, ''));
  }
  return lines;
}

// GitHub heading ids: lowercase, punctuation dropped (underscores kept), spaces to hyphens, repeats numbered.
const slugCache = new Map();
function headingSlugs(path) {
  if (!slugCache.has(path)) {
    const seen = new Map();
    const slugs = new Set();
    for (const line of prose(readFileSync(path, 'utf8'))) {
      const heading = line.match(/^#{1,6}\s+(.*?)\s*#*\s*$/);
      if (!heading) continue;
      const text = heading[1].replace(/\[([^\]]*)\]\([^)]*\)/g, '$1');
      const slug = text.toLowerCase().replace(/[^\p{L}\p{M}\p{N}\p{Pc} -]/gu, '').replace(/ /g, '-');
      const count = seen.get(slug) ?? 0;
      seen.set(slug, count + 1);
      slugs.add(count === 0 ? slug : `${slug}-${count}`);
    }
    slugCache.set(path, slugs);
  }
  return slugCache.get(path);
}

const failures = [];
let checked = 0;
for (const source of documents) {
  for (const line of prose(readFileSync(source, 'utf8'))) {
    for (const [, target] of line.matchAll(LINK)) {
      if (EXTERNAL.test(target)) continue;
      checked += 1;
      const [path, anchor] = target.split('#', 2);
      const destination = path ? join(dirname(source), decodeURIComponent(path)) : source;
      if (!existsSync(destination)) {
        failures.push(`${source}: missing ${target}`);
      } else if (anchor && statSync(destination).isFile() && !headingSlugs(destination).has(anchor)) {
        failures.push(`${source}: missing anchor #${anchor} in ${destination}`);
      }
    }
  }
}

console.log(`checked ${checked} relative links across ${documents.length} documents`);
if (failures.length > 0) {
  console.error(failures.join('\n'));
  process.exit(1);
}
