import { readFileSync, writeFileSync, readdirSync, mkdirSync, existsSync } from 'node:fs';
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

const LIFECYCLE_METHODS = new Set(['initialize', 'connect', 'disconnect']);
const LIFECYCLE_SUFFIX_RE = /(TargetConnected|TargetDisconnected|ValueChanged|ClassesChanged)$/;

// Top-level commas only, so a destructured param (`{ a = 1 } = {}`) stays one entry.
function splitParams(raw) {
  const params = [];
  let depth = 0;
  let current = '';
  for (const char of raw) {
    if (char === ',' && depth === 0) {
      params.push(current.trim());
      current = '';
      continue;
    }
    if ('{[('.includes(char)) depth++;
    else if ('}])'.includes(char)) depth--;
    current += char;
  }
  if (current.trim()) params.push(current.trim());
  return params;
}

// First parameter name separates an adapter, `onSelect(event)`, from an API, `select(value)`.
export function parseActionParams(source) {
  const signatures = new Map();
  const re = /^\s{2}(?:async\s+)?([a-zA-Z_$][\w$]*)\s*\(([^)]*)\)/gm;
  let match;
  while ((match = re.exec(source)) !== null) {
    const name = match[1];
    if (LIFECYCLE_METHODS.has(name)) continue;
    if (LIFECYCLE_SUFFIX_RE.test(name)) continue;
    if (!signatures.has(name)) signatures.set(name, splitParams(match[2]));
  }
  return Object.fromEntries([...signatures.keys()].sort().map((name) => [name, signatures.get(name)]));
}

export function parseActions(source) {
  return Object.keys(parseActionParams(source));
}

export function parseDispatches(source) {
  const names = new Set();
  const re = /\.dispatch\(\s*['"]([^'"]+)['"]/g;
  let match;
  while ((match = re.exec(source)) !== null) names.add(match[1]);
  return [...names].sort();
}

// Actions/dispatches can be defined in an imported plumber file rather than the
// controller itself (e.g. attachCalendarYearSelector dispatches 'selected' on
// behalf of calendar_decade_controller.js) — resolve those imports so parsing
// isn't blind to wiring that lives one level away from the controller class.
function resolvePlumberSource(importPath, controllersDir) {
  const plumbersDir = join(controllersDir, '..', 'plumbers');
  const rel = importPath.replace(/^\.\.\/plumbers\/?/, '');
  const base = rel ? join(plumbersDir, rel) : plumbersDir;
  return [`${base}.js`, join(base, 'index.js')].find((c) => existsSync(c)) ?? null;
}

export function withPlumberSources(source, controllersDir) {
  const importRe = /from\s+['"](\.\.\/plumbers[^'"]*)['"]/g;
  const importPaths = [...source.matchAll(importRe)].map((m) => m[1]);
  const extraSources = importPaths
    .map((p) => resolvePlumberSource(p, controllersDir))
    .filter(Boolean)
    .map((p) => readFileSync(p, 'utf8'));
  return [source, ...extraSources].join('\n');
}

export function parseArray(source, name) {
  const re = new RegExp(`static\\s+${name}\\s*=\\s*\\[([^\\]]*)\\]`, 's');
  const m = source.match(re);
  if (!m) return [];
  return [...m[1].matchAll(/['"]([^'"]+)['"]/g)].map((r) => r[1]);
}

// Finds the `static values = { ... }` block via balanced-brace scanning rather than a
// fixed-depth regex, so defaults that are themselves object/array literals (e.g.
// `default: {}`) don't break the match for the whole block.
function extractValuesBlock(source) {
  const start = source.match(/static\s+values\s*=\s*\{/);
  if (!start) return null;

  const openIndex = start.index + start[0].length - 1;
  let depth = 0;
  for (let i = openIndex; i < source.length; i++) {
    if (source[i] === '{') depth++;
    else if (source[i] === '}') {
      depth--;
      if (depth === 0) return source.slice(openIndex, i + 1);
    }
  }
  return null;
}

export function parseValues(source) {
  const block = extractValuesBlock(source);
  if (!block) return {};

  const result = {};

  // Full form: key: { type: Type, default: val }
  const fullRe = /(\w+)\s*:\s*\{\s*type\s*:\s*(\w+)(?:\s*,\s*default\s*:\s*(\{\}|\[\]|[^\n,}][^\n}]*?))?\s*\}/g;
  let match;
  while ((match = fullRe.exec(block)) !== null) {
    const entry = { type: match[2] };
    if (match[3] !== undefined) {
      const raw = match[3].trim().replace(/,$/, '');
      if (raw === 'true') entry.default = true;
      else if (raw === 'false') entry.default = false;
      else if (raw === '{}') entry.default = {};
      else if (raw === '[]') entry.default = [];
      else if (/^-?\d+$/.test(raw)) entry.default = parseInt(raw, 10);
      else if (/^-?\d*\.\d+$/.test(raw)) entry.default = parseFloat(raw);
      else entry.default = raw.replace(/^['"]|['"]$/g, '');
    }
    result[match[1]] = entry;
  }

  // Short form: key: Type — strip nested {…} first so inner `type: Foo` isn't captured.
  // Collapse literal empty-object defaults first so a field wrapper containing one
  // (e.g. `{ type: Object, default: {} }`) still reads as a single nesting level.
  const flatBlock = block.replace(/\{\}/g, '""').replace(/\{[^{}]*\}/g, '{}');
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
  const extendedSource = withPlumberSources(source, controllersDir);
  controllers[identifier] = {
    identifier,
    targets: parseArray(source, 'targets'),
    values: parseValues(source),
    outlets: parseArray(source, 'outlets'),
    classes: parseArray(source, 'classes'),
    actions: parseActions(extendedSource),
    actionParams: parseActionParams(extendedSource),
    dispatches: parseDispatches(extendedSource),
  };
}

mkdirSync(dirname(outputFile), { recursive: true });
writeFileSync(outputFile, JSON.stringify(controllers, null, 2));
console.log(`Written ${Object.keys(controllers).length} controllers to dist/controllers.manifest.json`);
