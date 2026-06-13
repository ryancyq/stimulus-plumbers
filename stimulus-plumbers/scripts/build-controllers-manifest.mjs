import { readFileSync, writeFileSync, readdirSync, mkdirSync } from 'node:fs';
import { join, dirname, basename } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const controllersDir = join(__dirname, '..', 'src', 'controllers');
const outputFile = join(__dirname, '..', 'dist', 'controllers.manifest.json');

function toIdentifier(filename) {
  return basename(filename, '.js')
    .replace(/_controller$/, '')
    .replace(/_/g, '-');
}

function parseArray(source, name) {
  const re = new RegExp(`static\\s+${name}\\s*=\\s*\\[([^\\]]*)\\]`, 's');
  const m = source.match(re);
  if (!m) return [];
  return [...m[1].matchAll(/['"]([^'"]+)['"]/g)].map((r) => r[1]);
}

function parseValues(source) {
  // Captures one-level-nested object: { key: Type } or { key: { type: Type, default: val } }
  const m = source.match(/static\s+values\s*=\s*(\{(?:[^{}]|\{[^{}]*\})*\})/s);
  if (!m) return {};

  const block = m[1];
  const result = {};

  // Full form: key: { type: Type, default: val }
  const fullRe = /(\w+)\s*:\s*\{\s*type\s*:\s*(\w+)(?:\s*,\s*default\s*:\s*([^\n,}][^\n}]*?))?\s*\}/g;
  let match;
  while ((match = fullRe.exec(block)) !== null) {
    const entry = { type: match[2] };
    if (match[3] !== undefined) {
      const raw = match[3].trim().replace(/,$/, '');
      if (raw === 'true') entry.default = true;
      else if (raw === 'false') entry.default = false;
      else if (/^-?\d+$/.test(raw)) entry.default = parseInt(raw, 10);
      else if (/^-?\d*\.\d+$/.test(raw)) entry.default = parseFloat(raw);
      else entry.default = raw.replace(/^['"]|['"]$/g, '');
    }
    result[match[1]] = entry;
  }

  // Short form: key: Type — strip nested {…} first so inner `type: Foo` isn't captured
  const flatBlock = block.replace(/\{[^{}]*\}/g, '{}');
  const shortRe = /(\w+)\s*:\s*(String|Number|Boolean|Array|Object)\s*[,\n}]/g;
  while ((match = shortRe.exec(flatBlock)) !== null) {
    if (!result[match[1]]) result[match[1]] = { type: match[2] };
  }

  return result;
}

const files = readdirSync(controllersDir)
  .filter((f) => f.endsWith('_controller.js'))
  .sort();

const controllers = {};
for (const file of files) {
  const identifier = toIdentifier(file);
  const source = readFileSync(join(controllersDir, file), 'utf8');
  controllers[identifier] = {
    identifier,
    targets: parseArray(source, 'targets'),
    values: parseValues(source),
    outlets: parseArray(source, 'outlets'),
    classes: parseArray(source, 'classes'),
  };
}

mkdirSync(dirname(outputFile), { recursive: true });
writeFileSync(outputFile, JSON.stringify(controllers, null, 2));
console.log(`Written ${Object.keys(controllers).length} controllers to dist/controllers.manifest.json`);
