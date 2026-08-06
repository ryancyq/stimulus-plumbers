import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import ProgressController from '../../../src/controllers/progress_controller'

describe('ProgressController', () => {
  let application

  beforeEach(() => {
    application = Application.start()
    application.register('progress', ProgressController)
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
  })

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="progress"]'),
      'progress'
    )

  describe('bar variant', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div role="progressbar" data-controller="progress"
             data-progress-current-value="30" data-progress-min-value="0" data-progress-max-value="100">
          <div data-progress-target="fill"></div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('sets aria-valuenow/valuemin/valuemax on connect', () => {
      const el = document.querySelector('[data-controller="progress"]')
      expect(el.getAttribute('aria-valuenow')).toBe('30')
      expect(el.getAttribute('aria-valuemin')).toBe('0')
      expect(el.getAttribute('aria-valuemax')).toBe('100')
    })

    it('sets the fill target width to match the percent', () => {
      const fill = document.querySelector('[data-progress-target="fill"]')
      expect(fill.style.width).toBe('30%')
    })

    it('publishes the percent on the root so a theme can split the readout at the fill edge', () => {
      const el = document.querySelector('[data-controller="progress"]')
      expect(el.style.getPropertyValue('--sp-progress-percent')).toBe('30')
      getController().setValue(80)
      expect(el.style.getPropertyValue('--sp-progress-percent')).toBe('80')
    })

    it('setValue(value) clamps to max and updates the fill', () => {
      getController().setValue(150)
      const el = document.querySelector('[data-controller="progress"]')
      const fill = document.querySelector('[data-progress-target="fill"]')
      expect(el.getAttribute('aria-valuenow')).toBe('100')
      expect(fill.style.width).toBe('100%')
    })

    it('setValue(value) clamps to min', () => {
      getController().setValue(-20)
      expect(document.querySelector('[data-controller="progress"]').getAttribute('aria-valuenow')).toBe('0')
    })

    it('setValue(value) dispatches progress:changed with { value, min, max }', () => {
      const el = document.querySelector('[data-controller="progress"]')
      const spy = vi.fn()
      el.addEventListener('progress:changed', spy)
      getController().setValue(75)
      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].detail).toEqual({ value: 75, min: 0, max: 100 })
    })

    it('direct attribute edits recalculate fill via currentValueChanged', async () => {
      const el = document.querySelector('[data-controller="progress"]')
      el.setAttribute('data-progress-current-value', '60')
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(document.querySelector('[data-progress-target="fill"]').style.width).toBe('60%')
    })
  })

  describe('ring variant', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <svg role="progressbar" data-controller="progress" data-progress-variant-value="ring"
             data-progress-current-value="25" data-progress-min-value="0" data-progress-max-value="100">
          <circle data-progress-target="fill" r="40"></circle>
        </svg>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('computes stroke-dasharray from the circle r attribute at connect', () => {
      const fill = document.querySelector('[data-progress-target="fill"]')
      const expected = 2 * Math.PI * 40
      expect(parseFloat(fill.style.strokeDasharray)).toBeCloseTo(expected, 2)
    })

    it('computes stroke-dashoffset for the given percent', () => {
      const fill = document.querySelector('[data-progress-target="fill"]')
      const circumference = 2 * Math.PI * 40
      const expected = circumference * (1 - 0.25)
      expect(parseFloat(fill.style.strokeDashoffset)).toBeCloseTo(expected, 2)
    })

    it('recalculates stroke-dashoffset on setValue', () => {
      getController().setValue(50)
      const fill = document.querySelector('[data-progress-target="fill"]')
      const circumference = 2 * Math.PI * 40
      const expected = circumference * (1 - 0.5)
      expect(parseFloat(fill.style.strokeDashoffset)).toBeCloseTo(expected, 2)
    })

    it('still sets aria-valuenow/valuemin/valuemax like the bar variant', () => {
      const el = document.querySelector('[data-controller="progress"]')
      expect(el.getAttribute('aria-valuenow')).toBe('25')
      expect(el.getAttribute('aria-valuemin')).toBe('0')
      expect(el.getAttribute('aria-valuemax')).toBe('100')
    })
  })

  describe('segmented variant', () => {
    const setup = async ({ value = 6, mode = null } = {}) => {
      const modeAttr = mode ? `data-progress-segment-mode-value="${mode}"` : ''
      document.body.innerHTML = `
        <div role="progressbar" data-controller="progress" data-progress-variant-value="segmented"
             data-progress-current-value="${value}" data-progress-max-value="10" ${modeAttr}>
          <div><div data-progress-target="fill"></div></div>
          <div><div data-progress-target="fill"></div></div>
          <div><div data-progress-target="fill"></div></div>
          <div><div data-progress-target="fill"></div></div>
          <div><div data-progress-target="fill"></div></div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    }
    const fillWidths = () =>
      [...document.querySelectorAll('[data-progress-target="fill"]')].map((f) => f.style.width)

    it('sets aria attrs on the container like the bar variant', async () => {
      await setup()
      const el = document.querySelector('[data-controller="progress"]')
      expect(el.getAttribute('aria-valuenow')).toBe('6')
      expect(el.getAttribute('aria-valuemax')).toBe('10')
    })

    it('discrete mode (default) lights whole segments reached by the value', async () => {
      await setup({ value: 6 })
      // 6/10 over 5 segments = 3 filled segments
      expect(fillWidths()).toEqual(['100%', '100%', '100%', '0%', '0%'])
    })

    it('discrete mode lights a segment as soon as progress enters it', async () => {
      await setup({ value: 5 })
      // 5/10 over 5 segments = 2.5 → segment 3 is entered, so lit
      expect(fillWidths()).toEqual(['100%', '100%', '100%', '0%', '0%'])
    })

    it('continuous mode partially fills the boundary segment', async () => {
      await setup({ value: 5, mode: 'continuous' })
      expect(fillWidths()).toEqual(['100%', '100%', '50%', '0%', '0%'])
    })

    it('setValue redistributes the fill across segments', async () => {
      await setup({ value: 6 })
      getController().setValue(2)
      expect(fillWidths()).toEqual(['100%', '0%', '0%', '0%', '0%'])
    })

    it('indeterminate gives every segment a chunk staggered by index/count into a relay', async () => {
      document.body.innerHTML = `
        <div role="progressbar" data-controller="progress" data-progress-variant-value="segmented"
             data-progress-indeterminate-value="true" data-progress-max-value="10">
          <div><div data-progress-target="fill"></div></div>
          <div><div data-progress-target="fill"></div></div>
          <div><div data-progress-target="fill"></div></div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
      const el = document.querySelector('[data-controller="progress"]')
      expect(el.hasAttribute('aria-valuenow')).toBe(false)
      expect(el.classList.contains('sp-progress-indeterminate')).toBe(true)
      expect(fillWidths()).toEqual(['25%', '25%', '25%'])
      const fillEls = [...document.querySelectorAll('[data-progress-target="fill"]')]
      expect(fillEls.map((f) => f.style.getPropertyValue('--sp-progress-index'))).toEqual(['0', '1', '2'])
      expect(fillEls.map((f) => f.style.getPropertyValue('--sp-progress-count'))).toEqual(['3', '3', '3'])
    })
  })

  describe('meter variant', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <meter data-controller="progress" data-progress-variant-value="meter" data-progress-target="meter"
               data-progress-current-value="40" data-progress-min-value="0" data-progress-max-value="100"
               data-progress-low-value="20" data-progress-high-value="80" data-progress-optimum-value="50"></meter>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('syncs value/min/max/low/high/optimum onto the native meter', () => {
      const meter = document.querySelector('[data-controller="progress"]')
      expect(meter.value).toBe(40)
      expect(meter.min).toBe(0)
      expect(meter.max).toBe(100)
      expect(meter.low).toBe(20)
      expect(meter.high).toBe(80)
      expect(meter.optimum).toBe(50)
    })

    it('does not set role=progressbar aria attrs', () => {
      const meter = document.querySelector('[data-controller="progress"]')
      expect(meter.hasAttribute('aria-valuenow')).toBe(false)
    })

    it('setValue updates the native meter value', () => {
      getController().setValue(70)
      expect(document.querySelector('[data-controller="progress"]').value).toBe(70)
    })
  })

  describe('meter variant with a non-meter target', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="progress" data-progress-variant-value="meter"
             data-progress-current-value="40" data-progress-min-value="0" data-progress-max-value="100">
          <div data-progress-target="meter"></div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('does not throw and leaves the target untouched', () => {
      const target = document.querySelector('[data-progress-target="meter"]')
      expect(target.value).toBeUndefined()
    })
  })

  describe('indeterminate bar', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div role="progressbar" data-controller="progress" data-progress-indeterminate-value="true">
          <div data-progress-target="fill"></div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('omits aria-valuenow', () => {
      expect(document.querySelector('[data-controller="progress"]').hasAttribute('aria-valuenow')).toBe(false)
    })

    it('adds the indeterminate animation class', () => {
      expect(
        document.querySelector('[data-controller="progress"]').classList.contains('sp-progress-indeterminate')
      ).toBe(true)
    })

    it('sets a fixed inline fill width as the static indeterminate baseline', () => {
      expect(document.querySelector('[data-progress-target="fill"]').style.width).toBe('25%')
    })
  })

  describe('indeterminate bar with a custom fraction', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div role="progressbar" data-controller="progress" data-progress-indeterminate-value="true"
             data-progress-indeterminate-fraction-value="0.4">
          <div data-progress-target="fill"></div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('sets the fill width to the overridden fraction', () => {
      expect(document.querySelector('[data-progress-target="fill"]').style.width).toBe('40%')
    })
  })

  describe('value readout', () => {
    const setup = async ({ value = 45, min = 0, max = 100, format = 'percent', indeterminate = false } = {}) => {
      document.body.innerHTML = `
        <div role="progressbar" data-controller="progress"
             data-progress-current-value="${value}" data-progress-min-value="${min}"
             data-progress-max-value="${max}" data-progress-indeterminate-value="${indeterminate}"
             data-progress-format-value="${format}">
          <div data-progress-target="fill"></div>
          <span data-progress-target="value" aria-hidden="true"></span>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    }
    const readout = () => document.querySelector('[data-progress-target="value"]')
    const host = () => document.querySelector('[data-controller="progress"]')
    const fill = () => document.querySelector('[data-progress-target="fill"]')

    it('renders the percentage when format is percent', async () => {
      await setup({ format: 'percent' })
      expect(readout().textContent).toBe('45%')
    })

    it('renders the raw value when format is value', async () => {
      await setup({ format: 'value' })
      expect(readout().textContent).toBe('45')
    })

    it('renders value and max when format is value_max', async () => {
      await setup({ format: 'value_max' })
      expect(readout().textContent).toBe('45 / 100')
    })

    it('updates the readout when setValue is called', async () => {
      await setup({ format: 'percent' })
      getController().setValue(80)
      expect(readout().textContent).toBe('80%')
    })

    it('leaves aria-valuetext unset for percent', async () => {
      await setup({ format: 'percent' })
      expect(host().hasAttribute('aria-valuetext')).toBe(false)
    })

    it('sets aria-valuetext for value_max', async () => {
      await setup({ format: 'value_max' })
      expect(host().getAttribute('aria-valuetext')).toBe('45 / 100')
    })

    it('clears the readout and aria-valuetext while indeterminate', async () => {
      await setup({ format: 'value_max', indeterminate: true })
      expect(readout().textContent).toBe('')
      expect(host().hasAttribute('aria-valuetext')).toBe(false)
    })

    it('leaves author-rendered text alone for an unknown format', async () => {
      document.body.innerHTML = `
        <div role="progressbar" data-controller="progress" data-progress-current-value="45"
             data-progress-max-value="100" data-progress-format-value="other">
          <div data-progress-target="fill"></div>
          <span data-progress-target="value">untouched</span>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(readout().textContent).toBe('untouched')
    })

    it('renders nothing extra when no value target is present', async () => {
      document.body.innerHTML = `
        <div role="progressbar" data-controller="progress" data-progress-current-value="45"
             data-progress-max-value="100" data-progress-format-value="percent">
          <div data-progress-target="fill"></div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(document.querySelector('[data-progress-target="fill"]').style.width).toBe('45%')
    })

    it('accounts for a non-zero minimum', async () => {
      await setup({ value: 15, min: 10, max: 20 })
      expect(readout().textContent).toBe('50%')
    })

    it('rounds to a whole number', async () => {
      await setup({ value: 1, max: 3 })
      expect(readout().textContent).toBe('33%')
    })

    it('is zero percent when the range is empty', async () => {
      await setup({ value: 5, min: 5, max: 5 })
      expect(readout().textContent).toBe('0%')
    })

    it('is zero percent when max is below min', async () => {
      await setup({ value: 5, min: 10, max: 0 })
      expect(readout().textContent).toBe('0%')
    })

    // Via the initial attribute, not setValue() — setValue clamps on the way in and hides the bug.
    it('clamps a value that arrives out of range in the markup', async () => {
      await setup({ value: 150, max: 100 })
      expect(readout().textContent).toBe('100%')
      expect(fill().style.width).toBe('100%')
      expect(host().getAttribute('aria-valuenow')).toBe('100')
    })

    it('clamps a value below the minimum', async () => {
      await setup({ value: -10, min: 0, max: 100 })
      expect(readout().textContent).toBe('0%')
      expect(fill().style.width).toBe('0%')
      expect(host().getAttribute('aria-valuenow')).toBe('0')
    })

    it('renders integral values without a decimal point', async () => {
      await setup({ value: '45.0', max: '100.0', format: 'value_max' })
      expect(readout().textContent).toBe('45 / 100')
    })
  })

  describe('range variant', () => {
    // The bare shape: no readout, so the controller sits on the input itself.
    const setup = async (attrs = {}) => {
      const { value = '45', min = '0', max = '100' } = attrs
      document.body.innerHTML = `
        <input type="range" min="${min}" max="${max}" value="${value}"
               data-controller="progress" data-progress-variant-value="range"
               data-progress-current-value="${value}"
               data-progress-min-value="${min}" data-progress-max-value="${max}"
               data-action="input->progress#refresh">
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
      return document.querySelector('input[type="range"]')
    }

    it('sets the fill percentage custom property on connect', async () => {
      const input = await setup()
      expect(input.style.getPropertyValue('--sp-progress-percent')).toBe('45')
    })

    it('updates the fill percentage as the user drags', async () => {
      const input = await setup()
      input.value = '80'
      input.dispatchEvent(new Event('input', { bubbles: true }))
      expect(input.style.getPropertyValue('--sp-progress-percent')).toBe('80')
    })

    it('scales the fill percentage against a non-zero minimum', async () => {
      const input = await setup({ value: '30', min: '20', max: '40' })
      expect(input.style.getPropertyValue('--sp-progress-percent')).toBe('50')
    })

    it('dispatches progress:changed as the user drags, like setValue does', async () => {
      const input = await setup()
      const spy = vi.fn()
      input.addEventListener('progress:changed', spy)
      input.value = '80'
      input.dispatchEvent(new Event('input', { bubbles: true }))
      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].detail).toEqual({ value: 80, min: 0, max: 100 })
    })

    it('setValue moves the native input, not just the fill', async () => {
      const input = await setup()
      getController().setValue(80)
      expect(input.value).toBe('80')
      expect(input.style.getPropertyValue('--sp-progress-percent')).toBe('80')
    })

    it('setValue writes the clamped value back to the input', async () => {
      const input = await setup()
      getController().setValue(150)
      expect(input.value).toBe('100')
    })

    it('adopts the input value when no current-value attribute is given', async () => {
      document.body.innerHTML = `
        <input type="range" min="0" max="100" value="70"
               data-controller="progress" data-progress-variant-value="range"
               data-action="input->progress#refresh">
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
      const input = document.querySelector('input[type="range"]')
      expect(input.value).toBe('70')
      expect(input.style.getPropertyValue('--sp-progress-percent')).toBe('70')
    })

    it('does not write aria-value attributes onto a native range', async () => {
      const input = await setup()
      expect(input.hasAttribute('aria-valuenow')).toBe(false)
      expect(input.hasAttribute('aria-valuemin')).toBe(false)
      expect(input.hasAttribute('aria-valuemax')).toBe(false)
    })
  })

  describe('range variant with a readout', () => {
    // With a readout the controller moves to a wrapper — a Stimulus target must be a
    // descendant of its controller element, so a sibling span would never resolve.
    const setup = async (format = 'percent') => {
      document.body.innerHTML = `
        <div data-controller="progress" data-progress-variant-value="range"
             data-progress-current-value="45" data-progress-min-value="0" data-progress-max-value="100"
             data-progress-format-value="${format}" data-action="input->progress#refresh">
          <input type="range" min="0" max="100" value="45" data-progress-target="input">
          <span data-progress-target="value" aria-hidden="true">45%</span>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
      return {
        input: document.querySelector('input[type="range"]'),
        readout: document.querySelector('[data-progress-target="value"]'),
      }
    }

    it('updates the readout as the user drags', async () => {
      const { input, readout } = await setup()
      input.value = '80'
      input.dispatchEvent(new Event('input', { bubbles: true }))
      expect(readout.textContent).toBe('80%')
    })

    it('paints the fill on the input, not the wrapper', async () => {
      const { input } = await setup()
      const wrapper = document.querySelector('[data-controller="progress"]')
      expect(input.style.getPropertyValue('--sp-progress-percent')).toBe('45')
      expect(wrapper.style.getPropertyValue('--sp-progress-percent')).toBe('')
    })

    // The native input announces its own value; aria-valuetext here would duplicate it.
    it('leaves aria-valuetext off a non-percent readout', async () => {
      const { input, readout } = await setup('value_max')
      const wrapper = document.querySelector('[data-controller="progress"]')
      expect(readout.textContent).toBe('45 / 100')
      expect(wrapper.hasAttribute('aria-valuetext')).toBe(false)
      expect(input.hasAttribute('aria-valuetext')).toBe(false)
    })
  })

  describe('indeterminate ring', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <svg role="progressbar" data-controller="progress" data-progress-variant-value="ring"
             data-progress-indeterminate-value="true">
          <circle data-progress-target="fill" r="40"></circle>
        </svg>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('sets stroke-dasharray to a fixed fraction of the circumference as the static indeterminate baseline', () => {
      const fill = document.querySelector('[data-progress-target="fill"]')
      const circumference = 2 * Math.PI * 40
      const [arc, gap] = fill.style.strokeDasharray.split(' ').map(parseFloat)
      expect(arc).toBeCloseTo(circumference * 0.25, 2)
      expect(gap).toBeCloseTo(circumference * 0.75, 2)
    })
  })
})
