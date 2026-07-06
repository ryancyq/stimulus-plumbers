import { describe, it, expect } from 'vitest'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import { parseActions, parseDispatches, withPlumberSources } from '../../scripts/build-controllers-manifest.mjs'

const CONTROLLERS_DIR = join(dirname(fileURLToPath(import.meta.url)), '../../src/controllers')

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
})

describe('parseDispatches', () => {
  it('collects unique dispatched event names', () => {
    expect(parseDispatches(POPOVER_SOURCE)).toEqual(['hidden', 'shown'])
  })

  it('returns an empty array when nothing is dispatched', () => {
    expect(parseDispatches('export default class extends Controller {}')).toEqual([])
  })
})

describe('withPlumberSources', () => {
  it('includes dispatch calls from an imported plumber file', () => {
    const source = `import { attachCalendarYearSelector } from '../plumbers/calendar-selector';`
    const combined = withPlumberSources(source, CONTROLLERS_DIR)
    expect(parseDispatches(combined)).toContain('selected')
  })

  it('returns just the source when there are no plumber imports', () => {
    expect(withPlumberSources('const x = 1;', CONTROLLERS_DIR)).toBe('const x = 1;')
  })
})
