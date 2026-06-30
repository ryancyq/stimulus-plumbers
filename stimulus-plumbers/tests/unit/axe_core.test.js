import { describe, it, expect } from 'vitest'
import axe from 'axe-core'

describe('axe-core', () => {
  it('exposes run and configure APIs', () => {
    expect(typeof axe.run).toBe('function')
    expect(typeof axe.configure).toBe('function')
  })
})
