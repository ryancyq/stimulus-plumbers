import { describe, it, expect } from 'vitest'
import { readFileSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import {
  parseActions,
  parseActionParams,
  parseDispatches,
  withPlumberSources,
  parseValues,
} from '../../scripts/build-controllers-manifest.mjs'

const CONTROLLERS_DIR = join(dirname(fileURLToPath(import.meta.url)), '../../src/controllers')
const MANIFEST_PATH = join(CONTROLLERS_DIR, '../../dist/controllers.manifest.json')

const POPOVER_SOURCE = `
export default class extends Controller {
  static targets = ['trigger', 'panel'];
  static values = { url: String };

  connect() {}
  disconnect() {}

  async open() {
    this.dispatch('shown', { detail: {} });
  }

  async close() {
    this.dispatch('hidden');
  }

  urlValueChanged() {}
  panelTargetConnected() {}

  #privateHelper() {
    return true;
  }
}
`

describe('parseActions', () => {
  it('excludes lifecycle callbacks and value/target callbacks', () => {
    const actions = parseActions(POPOVER_SOURCE)
    expect(actions).toContain('open')
    expect(actions).toContain('close')
    expect(actions).not.toContain('connect')
    expect(actions).not.toContain('disconnect')
    expect(actions).not.toContain('urlValueChanged')
    expect(actions).not.toContain('panelTargetConnected')
  })

  it('excludes private (#-prefixed) methods', () => {
    expect(parseActions(POPOVER_SOURCE)).not.toContain('privateHelper')
  })

  it('keeps the documented modal action surfaces exact', () => {
    const manifest = JSON.parse(readFileSync(MANIFEST_PATH, 'utf8'))

    expect(manifest.modal.actions).toEqual(['close', 'dismiss', 'open'])
    expect(manifest['modal-turbo'].actions).toEqual([
      'onBeforeFetchRequest',
      'onClosed',
      'onFrameRender',
      'onSubmitEnd',
    ])
    expect(manifest.modal.actionParams).toEqual({
      close: ['eventOrResult'],
      dismiss: ['eventOrResult'],
      open: ['event'],
    })
    expect(manifest['modal-turbo'].actionParams).toEqual({
      onBeforeFetchRequest: ['event'],
      onClosed: ['event'],
      onFrameRender: ['event'],
      onSubmitEnd: ['event'],
    })
  })
})

describe('parseActionParams', () => {
  const SOURCE = `
export default class extends Controller {
  connect() {}

  onSelect(event) {}

  select(value) {}

  async close() {}

  step(drum, delta) {}

  createDayElement(day, { selectable = false, disabled = false } = {}) {}
}
`

  it('distinguishes event adapters from programmatic APIs by first parameter', () => {
    const params = parseActionParams(SOURCE)
    expect(params.onSelect).toEqual(['event'])
    expect(params.select).toEqual(['value'])
  })

  it('records an empty list for methods that take no arguments', () => {
    expect(parseActionParams(SOURCE).close).toEqual([])
  })

  it('splits on top-level commas only, keeping destructured params intact', () => {
    expect(parseActionParams(SOURCE).step).toEqual(['drum', 'delta'])
    expect(parseActionParams(SOURCE).createDayElement).toEqual([
      'day',
      '{ selectable = false, disabled = false } = {}',
    ])
  })

  it('covers exactly the methods listed as actions', () => {
    expect(Object.keys(parseActionParams(POPOVER_SOURCE))).toEqual(parseActions(POPOVER_SOURCE))
  })
})

describe('parseDispatches', () => {
  it('collects unique dispatched event names', () => {
    expect(parseDispatches(POPOVER_SOURCE)).toEqual(['hidden', 'shown'])
  })

  it('collects event names dispatched through a private helper', () => {
    expect(parseDispatches("this.#dispatch('opened')")).toEqual(['opened'])
  })

  it('returns an empty array when nothing is dispatched', () => {
    expect(parseDispatches('export default class extends Controller {}')).toEqual([])
  })
})

describe('parseValues', () => {
  it('parses short-form and full-form entries', () => {
    const source = `
export default class extends Controller {
  static values = { url: String, count: { type: Number, default: 3 } };
}
`
    expect(parseValues(source)).toEqual({
      url: { type: 'String' },
      count: { type: 'Number', default: 3 },
    })
  })

  it('does not lose sibling entries when one default is itself an object/array literal', () => {
    const source = `
export default class extends Controller {
  static values = {
    format: { type: String, default: 'plain' },
    options: { type: Object, default: {} },
    groups: { type: Array, default: [] },
  };
}
`
    expect(parseValues(source)).toEqual({
      format: { type: 'String', default: 'plain' },
      options: { type: 'Object', default: {} },
      groups: { type: 'Array', default: [] },
    })
  })

  it('returns an empty object when there is no values block', () => {
    expect(parseValues('export default class extends Controller {}')).toEqual({})
  })
})

describe('withPlumberSources', () => {
  it('includes dispatch calls from an imported plumber file', () => {
    const source = `import { attachCalendarYearSelector } from '../plumbers/calendar-selector';`
    const combined = withPlumberSources(source, CONTROLLERS_DIR)
    expect(parseDispatches(combined)).toContain('selected')
  })

  it('retains dispatches from an imported plumber without treating them as controller methods', () => {
    const source = readFileSync(join(CONTROLLERS_DIR, 'modal_controller.js'), 'utf8')
    const combined = withPlumberSources(source, CONTROLLERS_DIR)

    expect(parseActions(source)).toEqual(['close', 'dismiss', 'open'])
    expect(parseDispatches(source)).toEqual([])
    expect(parseDispatches(combined)).toEqual(['before-dismiss', 'before-open', 'closed', 'opened'])
  })

  it('returns just the source when there are no plumber imports', () => {
    expect(withPlumberSources('const x = 1;', CONTROLLERS_DIR)).toBe('const x = 1;')
  })
})
