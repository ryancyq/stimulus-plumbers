/**
 * @stimulus-plumbers/controllers
 *
 * Stimulus Plumbers controllers for UI components
 * Following WCAG 2.1+ and WAI-ARIA best practices
 */

// Export accessibility utilities
export * from './accessibility/focus.js';
export * from './accessibility/keyboard.js';
export * from './accessibility/aria.js';

// Export utilities
export { Requestor } from './requestor.js';
export { fuzzyMatcher, filterOptions } from './researcher.js';

export { Formatter, FORMATTER_TYPES } from './plumbers/formatter.js';

// Export Stimulus controllers
export { default as CalendarDecadeController } from './controllers/calendar_decade_controller.js';
export { default as CalendarDecadeSelectorController } from './controllers/calendar_decade_selector_controller.js';
export { default as CalendarMonthController } from './controllers/calendar_month_controller.js';
export { default as CalendarMonthSelectorController } from './controllers/calendar_month_selector_controller.js';
export { default as CalendarYearController } from './controllers/calendar_year_controller.js';
export { default as CalendarYearSelectorController } from './controllers/calendar_year_selector_controller.js';
export { default as ClipboardController } from './controllers/clipboard_controller.js';
export { default as ComboboxDateController } from './controllers/combobox_date_controller.js';
export { default as ComboboxDropdownController } from './controllers/combobox_dropdown_controller.js';
export { default as ComboboxTimeController } from './controllers/combobox_time_controller.js';
export { default as DismisserController } from './controllers/dismisser_controller.js';
export { default as FlipperController } from './controllers/flipper_controller.js';
export { default as InputComboboxController } from './controllers/input_combobox_controller.js';
export { default as InputFormatterController } from './controllers/input_formatter_controller.js';
export { default as InputClearableController } from './controllers/input_clearable_controller.js';
export { default as ModalController } from './controllers/modal_controller.js';
export { default as PannerController } from './controllers/panner_controller.js';
export { default as PopoverController } from './controllers/popover_controller.js';
export { default as ReorderableController } from './controllers/reorderable_controller.js';
export { default as TimelineController } from './controllers/timeline_controller.js';
