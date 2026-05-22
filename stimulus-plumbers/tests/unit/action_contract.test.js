import { describe, it, expect } from 'vitest'
import { readFileSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'

import InputComboboxController         from '../../src/controllers/input_combobox_controller'
import ComboboxDropdownController      from '../../src/controllers/combobox_dropdown_controller'
import ComboboxTimeController          from '../../src/controllers/combobox_time_controller'
import ComboboxDateController          from '../../src/controllers/combobox_date_controller'
import InputFormatterController        from '../../src/controllers/input_formatter_controller'
import InputClearableController        from '../../src/controllers/input_clearable_controller'
import CalendarMonthController         from '../../src/controllers/calendar_month_controller'
import CalendarMonthObserverController from '../../src/controllers/calendar_month_observer_controller'

const CONTROLLERS_DIR = resolve(
  dirname(fileURLToPath(import.meta.url)),
  '../../src/controllers'
)

function src(filename) {
  return readFileSync(resolve(CONTROLLERS_DIR, filename), 'utf8')
}

function identifierFromFile(filename) {
  return filename.replace(/_controller\.js$/, '').replaceAll('_', '-')
}

// ─── Method contract ──────────────────────────────────────────────────────────
// Every method name referenced in a Ruby data-action string.
// If you rename a method in JS or change an action in Ruby, update this list.

describe('Ruby action binding contract', () => {
  describe('method names', () => {
    const METHOD_CONTRACT = [
      ['input-combobox',          InputComboboxController,         ['open', 'close', 'onSelect', 'onInput']],
      ['combobox-dropdown',       ComboboxDropdownController,      ['select', 'onNavigate']],
      ['combobox-time',           ComboboxTimeController,          ['select', 'onNavigate']],
      ['combobox-date',           ComboboxDateController,          ['onSelect']],
      ['input-formatter',         InputFormatterController,        ['format', 'toggle']],
      ['input-clearable',         InputClearableController,        ['clear']],
      ['calendar-month',          CalendarMonthController,         ['onSelect']],
      ['calendar-month-observer', CalendarMonthObserverController, ['onSelect', 'select']],
    ]

    for (const [identifier, Controller, methods] of METHOD_CONTRACT) {
      describe(identifier, () => {
        for (const method of methods) {
          it(`exposes #${method}`, () => {
            expect(typeof Controller.prototype[method]).toBe('function')
          })
        }
      })
    }
  })

  // ─── Dispatch contract ────────────────────────────────────────────────────
  // Every custom event referenced in a Ruby data-action string as a listener.
  // Ruby listens to {controllerIdentifier}:{eventSuffix}.
  // Stimulus derives the identifier from the filename by convention.

  describe('custom event names', () => {
    const DISPATCH_CONTRACT = [
      ['calendar-month-observer', 'calendar_month_observer_controller.js', 'selected'],
      ['combobox-date',           'combobox_date_controller.js',           'selected'],
      ['combobox-dropdown',       'combobox_dropdown_controller.js',       'selected'],
      ['combobox-time',           'combobox_time_controller.js',           'selected'],
      ['input-combobox',          'input_combobox_controller.js',          'changed'],
    ]

    for (const [identifier, filename, eventSuffix] of DISPATCH_CONTRACT) {
      describe(`${identifier}:${eventSuffix}`, () => {
        it('controller identifier matches filename', () => {
          expect(identifierFromFile(filename)).toBe(identifier)
        })

        it(`dispatches '${eventSuffix}' in source`, () => {
          expect(src(filename)).toMatch(`dispatch('${eventSuffix}'`)
        })
      })
    }
  })
})
