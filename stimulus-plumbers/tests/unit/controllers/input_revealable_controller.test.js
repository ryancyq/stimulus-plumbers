import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { Application } from '@hotwired/stimulus'
import InputRevealableController from '../../../src/controllers/input_revealable_controller'

describe('InputRevealableController', () => {
  let application

  beforeEach(() => {
    application = Application.start()
    application.register('input-revealable', InputRevealableController)
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
  })

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="input-revealable"]'),
      'input-revealable'
    )

  describe('with reveal icons', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div
          data-controller="input-revealable"
          data-input-revealable-reveal-label-value="Show secret"
          data-input-revealable-conceal-label-value="Hide secret"
        >
          <input type="password" value="secret" data-input-revealable-target="input">
          <button aria-label="Show secret" data-action="input-revealable#toggle" data-input-revealable-target="toggle">
            <svg data-input-revealable-target="revealIcon"></svg>
            <svg data-input-revealable-target="concealIcon" hidden></svg>
          </button>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('swaps the visible SVG icon on toggle', async () => {
      const revealIcon = document.querySelector('[data-input-revealable-target="revealIcon"]')
      const concealIcon = document.querySelector('[data-input-revealable-target="concealIcon"]')

      expect(revealIcon.hasAttribute('hidden')).toBe(false)
      expect(concealIcon.hasAttribute('hidden')).toBe(true)
      expect(revealIcon.hidden).toBeUndefined()

      getController().toggle()
      await new Promise((resolve) => setTimeout(resolve, 10))

      expect(revealIcon.hasAttribute('hidden')).toBe(true)
      expect(concealIcon.hasAttribute('hidden')).toBe(false)
    })

    it('swaps the toggle label to name the next action', async () => {
      const toggle = document.querySelector('[data-input-revealable-target="toggle"]')

      expect(toggle.getAttribute('aria-label')).toBe('Show secret')
      getController().toggle()
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(toggle.getAttribute('aria-label')).toBe('Hide secret')
    })

    it('flips the input type between password and text', async () => {
      const input = document.querySelector('[data-input-revealable-target="input"]')

      expect(input.type).toBe('password')
      getController().toggle()
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(input.type).toBe('text')
      getController().toggle()
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(input.type).toBe('password')
    })
  })

  it('toggles without icon targets present', async () => {
    document.body.innerHTML = `
      <div data-controller="input-revealable">
        <input type="password" data-input-revealable-target="input">
        <button data-action="input-revealable#toggle" data-input-revealable-target="toggle">Toggle</button>
      </div>
    `
    await new Promise((resolve) => setTimeout(resolve, 10))

    expect(() => getController().toggle()).not.toThrow()
    expect(getController().revealedValue).toBe(true)
  })

  it('keeps a lone reveal icon visible and swaps only the label', async () => {
    document.body.innerHTML = `
      <div data-controller="input-revealable" data-input-revealable-conceal-label-value="Hide secret">
        <input type="password" data-input-revealable-target="input">
        <button aria-label="Show secret" data-input-revealable-target="toggle">
          <svg data-input-revealable-target="revealIcon"></svg>
        </button>
      </div>
    `
    await new Promise((resolve) => setTimeout(resolve, 10))

    getController().toggle()
    await new Promise((resolve) => setTimeout(resolve, 10))

    const toggle = document.querySelector('[data-input-revealable-target="toggle"]')
    expect(document.querySelector('[data-input-revealable-target="revealIcon"]').hasAttribute('hidden')).toBe(false)
    expect(toggle.getAttribute('aria-label')).toBe('Hide secret')
  })

  it('keeps a lone conceal icon visible and swaps only the label', async () => {
    document.body.innerHTML = `
      <div data-controller="input-revealable" data-input-revealable-conceal-label-value="Hide secret">
        <input type="password" data-input-revealable-target="input">
        <button aria-label="Show secret" data-input-revealable-target="toggle">
          <svg data-input-revealable-target="concealIcon"></svg>
        </button>
      </div>
    `
    await new Promise((resolve) => setTimeout(resolve, 10))

    getController().toggle()
    await new Promise((resolve) => setTimeout(resolve, 10))

    const toggle = document.querySelector('[data-input-revealable-target="toggle"]')
    expect(document.querySelector('[data-input-revealable-target="concealIcon"]').hasAttribute('hidden')).toBe(false)
    expect(toggle.getAttribute('aria-label')).toBe('Hide secret')
  })

  it('preserves a readonly input value while toggling', async () => {
    document.body.innerHTML = `
      <div data-controller="input-revealable">
        <input type="password" readonly value="recovery-code" data-input-revealable-target="input">
      </div>
    `
    await new Promise((resolve) => setTimeout(resolve, 10))

    getController().toggle()
    await new Promise((resolve) => setTimeout(resolve, 10))

    const input = document.querySelector('[data-input-revealable-target="input"]')
    expect(input.type).toBe('text')
    expect(input.value).toBe('recovery-code')
  })

  it('keeps password markup concealed when revealed defaults to false', async () => {
    document.body.innerHTML = `
      <div data-controller="input-revealable">
        <input type="password" data-input-revealable-target="input">
      </div>
    `
    await new Promise((resolve) => setTimeout(resolve, 10))

    expect(document.querySelector('[data-input-revealable-target="input"]').type).toBe('password')
  })

  it('reconciles server-set revealed state with password markup', async () => {
    document.body.innerHTML = `
      <div data-controller="input-revealable" data-input-revealable-revealed-value="true">
        <input type="password" data-input-revealable-target="input">
      </div>
    `
    await new Promise((resolve) => setTimeout(resolve, 10))

    expect(document.querySelector('[data-input-revealable-target="input"]').type).toBe('text')
  })
})
