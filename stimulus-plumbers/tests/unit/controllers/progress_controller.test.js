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
