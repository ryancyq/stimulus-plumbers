import { describe, it, expect, beforeEach, vi } from 'vitest'
import { attachCharacterCells } from '../../../src/plumbers/character_cells'

const buildCells = (count) =>
  Array.from({ length: count }, () => {
    const cell = document.createElement('div')
    document.body.appendChild(cell)
    return cell
  })

const buildController = (cells) => ({
  element: document.body,
  identifier: 'input-formatter',
  dispatch: vi.fn(),
  cellTargets: cells,
})

describe('CharacterCells', () => {
  beforeEach(() => {
    document.body.innerHTML = ''
  })

  describe('adoption', () => {
    it('stamps aria-hidden on every cell', () => {
      const cells = buildCells(4)
      attachCharacterCells(buildController(cells), { length: 4 })
      cells.forEach((cell) => expect(cell.getAttribute('aria-hidden')).toBe('true'))
    })

    it('marks cells beyond the expected length as data-inactive', () => {
      const cells = buildCells(8)
      attachCharacterCells(buildController(cells), { length: 6 })
      expect(cells[5].hasAttribute('data-inactive')).toBe(false)
      expect(cells[6].hasAttribute('data-inactive')).toBe(true)
      expect(cells[7].hasAttribute('data-inactive')).toBe(true)
    })

    it('warns once when there are fewer cells than expected', () => {
      const warn = vi.spyOn(console, 'warn').mockImplementation(() => {})
      attachCharacterCells(buildController(buildCells(4)), { length: 6 })
      expect(warn).toHaveBeenCalledTimes(1)
      warn.mockRestore()
    })

    it('stamps group attributes when groups are configured', () => {
      const cells = buildCells(8)
      attachCharacterCells(buildController(cells), { groups: [4, 4] })
      expect(cells[0].getAttribute('data-group-index')).toBe('0')
      expect(cells[3].hasAttribute('data-group-end')).toBe(true)
      expect(cells[4].getAttribute('data-group-index')).toBe('1')
      expect(cells[4].hasAttribute('data-group-end')).toBe(false)
      expect(cells[7].hasAttribute('data-group-end')).toBe(true)
    })

    it('derives expected length from groups sum when length is unset', () => {
      const cells = buildCells(8)
      const controller = buildController(cells)
      attachCharacterCells(controller, { groups: [4, 4] })
      expect(controller.characterCells.active()).toBe(8)
    })

    it('derives expected length from cell count when nothing is configured', () => {
      const controller = buildController(buildCells(5))
      attachCharacterCells(controller, {})
      expect(controller.characterCells.active()).toBe(5)
    })
  })

  describe('re-attachment idempotency', () => {
    it('removes stale group attributes when re-attached with fewer/no groups', () => {
      const cells = buildCells(16)
      const controller = buildController(cells)
      attachCharacterCells(controller, { groups: [4, 4, 4, 4] })
      expect(cells[3].hasAttribute('data-group-end')).toBe(true)
      expect(cells[4].getAttribute('data-group-index')).toBe('1')

      attachCharacterCells(controller, { length: 6 })
      cells.forEach((cell) => {
        expect(cell.hasAttribute('data-group-index')).toBe(false)
        expect(cell.hasAttribute('data-group-end')).toBe(false)
      })
    })

    it('clears stale textContent and data-filled on cells that become inactive after a shrink', () => {
      const cells = buildCells(6)
      const controller = buildController(cells)
      attachCharacterCells(controller, { length: 6 })
      controller.characterCells.draw('482913')
      expect(cells[5].textContent).toBe('3')
      expect(cells[5].hasAttribute('data-filled')).toBe(true)

      attachCharacterCells(controller, { length: 4 })
      expect(cells[4].textContent).toBe('')
      expect(cells[4].hasAttribute('data-filled')).toBe(false)
      expect(cells[5].textContent).toBe('')
      expect(cells[5].hasAttribute('data-filled')).toBe(false)
    })

    it('draw() clears stale content on cells beyond the (now smaller) active count', () => {
      const cells = buildCells(6)
      const controller = buildController(cells)
      attachCharacterCells(controller, { length: 6 })
      controller.characterCells.draw('482913')

      attachCharacterCells(controller, { length: 4 })
      controller.characterCells.draw('4829')
      expect(cells.map((cell) => cell.textContent)).toEqual(['4', '8', '2', '9', '', ''])
      expect(cells[4].hasAttribute('data-filled')).toBe(false)
      expect(cells[5].hasAttribute('data-filled')).toBe(false)
    })
  })

  describe('draw', () => {
    let cells, controller

    beforeEach(() => {
      cells = buildCells(6)
      controller = buildController(cells)
      attachCharacterCells(controller, { length: 6 })
    })

    it('writes one character per cell and clears the rest', () => {
      controller.characterCells.draw('482')
      expect(cells.map((cell) => cell.textContent)).toEqual(['4', '8', '2', '', '', ''])
    })

    it('stamps data-filled on cells holding a character', () => {
      controller.characterCells.draw('482')
      expect(cells[2].hasAttribute('data-filled')).toBe(true)
      expect(cells[3].hasAttribute('data-filled')).toBe(false)
    })

    it('stamps data-caret at the input position only when focused', () => {
      controller.characterCells.draw('482', { focused: true })
      expect(cells[3].hasAttribute('data-caret')).toBe(true)
      controller.characterCells.draw('482', { focused: false })
      expect(cells[3].hasAttribute('data-caret')).toBe(false)
    })

    it('stamps no caret when the value is full', () => {
      controller.characterCells.draw('482913', { focused: true })
      expect(cells.some((cell) => cell.hasAttribute('data-caret'))).toBe(false)
    })

    it('clear() empties every cell', () => {
      controller.characterCells.draw('482913')
      controller.characterCells.clear()
      expect(cells.every((cell) => cell.textContent === '')).toBe(true)
      expect(cells.some((cell) => cell.hasAttribute('data-filled'))).toBe(false)
    })

    it('ignores non-string values', () => {
      controller.characterCells.draw(null)
      expect(cells.every((cell) => cell.textContent === '')).toBe(true)
    })
  })

  describe('grouped cells (one cell per group)', () => {
    let cells, controller

    beforeEach(() => {
      cells = buildCells(4)
      controller = buildController(cells)
      attachCharacterCells(controller, { groups: [4, 4, 4, 4] })
    })

    it('is inferred when cell count matches group count', () => {
      expect(controller.characterCells.active()).toBe(16)
    })

    it('stamps data-group-index per cell and no data-group-end', () => {
      expect(cells.map((cell) => cell.getAttribute('data-group-index'))).toEqual(['0', '1', '2', '3'])
      cells.forEach((cell) => expect(cell.hasAttribute('data-group-end')).toBe(false))
    })

    it('writes a 4-character chunk per cell', () => {
      controller.characterCells.draw('4242424242424242')
      expect(cells.map((cell) => cell.textContent)).toEqual(['4242', '4242', '4242', '4242'])
    })

    it('writes partial chunks and clears cells beyond the filled prefix', () => {
      controller.characterCells.draw('42424')
      expect(cells.map((cell) => cell.textContent)).toEqual(['4242', '4', '', ''])
    })

    it('stamps data-filled only on cells holding characters', () => {
      controller.characterCells.draw('42424')
      expect(cells[0].hasAttribute('data-filled')).toBe(true)
      expect(cells[1].hasAttribute('data-filled')).toBe(true)
      expect(cells[2].hasAttribute('data-filled')).toBe(false)
    })

    it('stamps data-caret on the cell containing the input position, only while focused', () => {
      controller.characterCells.draw('42424', { focused: true })
      expect(cells[1].hasAttribute('data-caret')).toBe(true)
      expect(cells[0].hasAttribute('data-caret')).toBe(false)
      controller.characterCells.draw('42424', { focused: false })
      expect(cells[1].hasAttribute('data-caret')).toBe(false)
    })

    it('stamps no caret when the value is full', () => {
      controller.characterCells.draw('4242424242424242', { focused: true })
      expect(cells.some((cell) => cell.hasAttribute('data-caret'))).toBe(false)
    })
  })
})
