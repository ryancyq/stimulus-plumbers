import { describe, it, expect, beforeEach } from 'vitest'
import { defineRect, directionMap, viewportRect, isWithinViewport } from '../../../../src/plumbers/plumber/geometry'

describe('geometry utilities', () => {
  describe('defineRect', () => {
    it('creates a rect object with proper properties', () => {
      const rect = defineRect({ x: 10, y: 20, width: 100, height: 50 })

      expect(rect).toEqual({
        x: 10,
        y: 20,
        width: 100,
        height: 50,
        left: 10,
        right: 110,
        top: 20,
        bottom: 70,
      })
    })

    it('handles zero values', () => {
      const rect = defineRect({ x: 0, y: 0, width: 0, height: 0 })

      expect(rect).toEqual({
        x: 0,
        y: 0,
        width: 0,
        height: 0,
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
      })
    })

    it('handles negative values', () => {
      const rect = defineRect({ x: -10, y: -20, width: 100, height: 50 })
      expect(rect.left).toBe(-10)
      expect(rect.right).toBe(90)
      expect(rect.top).toBe(-20)
      expect(rect.bottom).toBe(30)
    })
  })

  describe('directionMap', () => {
    it('maps opposite directions correctly', () => {
      expect(directionMap.top).toBe('bottom')
      expect(directionMap.bottom).toBe('top')
      expect(directionMap.left).toBe('right')
      expect(directionMap.right).toBe('left')
    })
  })

  describe('viewportRect', () => {
    it('returns viewport dimensions as a rect', () => {
      const rect = viewportRect()
      expect(rect.x).toBe(0)
      expect(rect.y).toBe(0)
      expect(rect.width).toBe(window.innerWidth)
      expect(rect.height).toBe(window.innerHeight)
    })

    it('uses documentElement dimensions when window dimensions unavailable', () => {
      const originalInnerWidth = window.innerWidth
      const originalInnerHeight = window.innerHeight

      Object.defineProperty(window, 'innerWidth', { writable: true, configurable: true, value: undefined })
      Object.defineProperty(window, 'innerHeight', { writable: true, configurable: true, value: undefined })

      const rect = viewportRect()
      expect(rect.width).toBe(document.documentElement.clientWidth)
      expect(rect.height).toBe(document.documentElement.clientHeight)

      Object.defineProperty(window, 'innerWidth', { writable: true, configurable: true, value: originalInnerWidth })
      Object.defineProperty(window, 'innerHeight', { writable: true, configurable: true, value: originalInnerHeight })
    })
  })

  describe('isWithinViewport', () => {
    beforeEach(() => {
      document.body.innerHTML = ''
    })

    it('returns false for non-HTMLElement', () => {
      expect(isWithinViewport(null)).toBe(false)
      expect(isWithinViewport(undefined)).toBe(false)
      expect(isWithinViewport({})).toBe(false)
    })

    it('returns true for element fully within viewport', () => {
      const element = document.createElement('div')
      document.body.appendChild(element)
      element.getBoundingClientRect = () => ({ top: 100, left: 100, width: 200, height: 200 })
      expect(isWithinViewport(element)).toBe(true)
    })

    it('returns false for element completely outside viewport (top)', () => {
      const element = document.createElement('div')
      document.body.appendChild(element)
      element.getBoundingClientRect = () => ({ top: -300, left: 100, width: 200, height: 200 })
      expect(isWithinViewport(element)).toBe(false)
    })

    it('returns false for element completely outside viewport (left)', () => {
      const element = document.createElement('div')
      document.body.appendChild(element)
      element.getBoundingClientRect = () => ({ top: 100, left: -300, width: 200, height: 200 })
      expect(isWithinViewport(element)).toBe(false)
    })

    it('returns true for partially visible element', () => {
      const element = document.createElement('div')
      document.body.appendChild(element)
      element.getBoundingClientRect = () => ({ top: -50, left: -50, width: 200, height: 200 })
      expect(isWithinViewport(element)).toBe(true)
    })
  })
})
