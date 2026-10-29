import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Dismisser } from '../../../../src/plumbers/dismisser'
import { Shifter } from '../../../../src/plumbers/shifter'

describe('WindowObserver', () => {
  let controller
  let element
  let shifter

  beforeEach(() => {
    element = document.createElement('div')
    element.getBoundingClientRect = () => ({ x: 100, y: 100, top: 100, left: 100, width: 200, height: 200 })
    document.body.appendChild(element)
    controller = { identifier: 'observer', element, dispatch: vi.fn(() => true) }
  })

  afterEach(() => {
    shifter?.disconnect()
    document.body.innerHTML = ''
  })

  it('leaves other observers on the same controller listening after one disconnects', () => {
    const dismisser = new Dismisser(controller)
    shifter = new Shifter(controller)

    dismisser.disconnect()
    document.body.click()
    window.dispatchEvent(new Event('resize'))

    const dispatched = controller.dispatch.mock.calls.map(([name]) => name)
    expect(dispatched).not.toContain('dismiss')
    expect(dispatched).toContain('shift')
  })
})
