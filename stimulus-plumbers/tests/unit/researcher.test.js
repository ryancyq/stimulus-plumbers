import { describe, it, expect, beforeEach } from 'vitest'
import { fuzzyMatcher, filterOptions } from '../../src/researcher'

describe('fuzzyMatcher', () => {
  it('empty needle matches any haystack', () => {
    expect(fuzzyMatcher('', 'anything')).toBe(true)
  })

  it('returns true when needle chars appear in order in haystack', () => {
    expect(fuzzyMatcher('app', 'apple')).toBe(true)
    expect(fuzzyMatcher('apl', 'apple')).toBe(true)
  })

  it('returns false when needle chars are out of order', () => {
    expect(fuzzyMatcher('ppa', 'apple')).toBe(false)
  })

  it('returns false when needle is longer than haystack', () => {
    expect(fuzzyMatcher('toolong', 'too')).toBe(false)
  })

  it('returns true for an exact match', () => {
    expect(fuzzyMatcher('apple', 'apple')).toBe(true)
  })

  it('returns false when haystack is empty and needle is not', () => {
    expect(fuzzyMatcher('a', '')).toBe(false)
  })
})

describe('filterOptions', () => {
  let listbox

  beforeEach(() => {
    listbox = document.createElement('ul')
    listbox.innerHTML = `
      <li role="option">Apple</li>
      <li role="option">Banana</li>
      <li role="option">Apricot</li>
    `
    document.body.appendChild(listbox)
  })

  it('hides non-matching options and returns visible count', () => {
    const visible = filterOptions(listbox, 'ban')
    expect(visible).toBe(1)
    const opts = listbox.querySelectorAll('[role="option"]')
    expect(opts[0].hidden).toBe(true)   // Apple
    expect(opts[1].hidden).toBe(false)  // Banana
    expect(opts[2].hidden).toBe(true)   // Apricot
  })

  it('returns 0 when no options match', () => {
    const visible = filterOptions(listbox, 'xyz')
    expect(visible).toBe(0)
    listbox.querySelectorAll('[role="option"]').forEach((o) => expect(o.hidden).toBe(true))
  })

  it('shows all options when query matches all', () => {
    const visible = filterOptions(listbox, 'a')
    expect(visible).toBe(3)
    listbox.querySelectorAll('[role="option"]').forEach((o) => expect(o.hidden).toBe(false))
  })

  it('matches against a custom attribute field', () => {
    listbox.innerHTML = `
      <li role="option" data-label="United States">US</li>
      <li role="option" data-label="United Kingdom">UK</li>
      <li role="option" data-label="Germany">DE</li>
    `
    const visible = filterOptions(listbox, 'united', { fields: ['data-label'] })
    expect(visible).toBe(2)
  })

  it('matches against multiple fields', () => {
    listbox.innerHTML = `
      <li role="option" data-label="United States" data-value="us">US</li>
      <li role="option" data-label="Germany" data-value="de">DE</li>
    `
    const visible = filterOptions(listbox, 'de', { fields: ['textContent', 'data-value'] })
    expect(visible).toBe(1)
  })

  it('uses contains strategy', () => {
    const visible = filterOptions(listbox, 'ana', { strategy: 'contains' })
    expect(visible).toBe(1) // Banana
  })

  it('uses prefix strategy', () => {
    const visible = filterOptions(listbox, 'apr', { strategy: 'prefix' })
    expect(visible).toBe(1) // Apricot
  })

  it('uses a custom matcher function', () => {
    const matcher = (needle, haystack) => haystack === needle
    const visible = filterOptions(listbox, 'apple', { matcher })
    expect(visible).toBe(1)
  })
})
