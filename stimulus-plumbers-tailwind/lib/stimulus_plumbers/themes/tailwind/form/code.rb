# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Form
        module Code
          FIELD = %w[
            relative inline-flex w-fit rounded-(--sp-radius-md)
            focus-within:ring-(length:--sp-focus-ring-width) focus-within:ring-(--sp-focus-ring-color)
            focus-within:ring-offset-(length:--sp-focus-ring-offset)
          ].freeze
          FIELD_ERROR = %w[focus-within:ring-(--sp-color-error)].freeze
          CELLS = %w[flex items-center gap-(--sp-space-1)].freeze
          CELL = %w[
            flex size-10 items-center justify-center rounded-(--sp-radius-md) border
            border-(--sp-color-muted-fg) bg-(--sp-color-bg)
            text-(length:--sp-text-lg) font-medium text-(--sp-color-fg)
            transition-colors
            data-[filled]:border-(--sp-color-fg)
            data-[caret]:border-(--sp-color-primary) data-[caret]:ring-1 data-[caret]:ring-(--sp-color-primary)
            data-[group-end]:me-(--sp-space-2)
          ].freeze
          CELL_ERROR = %w[border-(--sp-color-error) data-[caret]:ring-(--sp-color-error)].freeze
          OVERLAY = %w[absolute inset-0 size-full cursor-text opacity-0 disabled:cursor-not-allowed].freeze

          private

          def form_field_input_code_classes(error: false) = { classes: klasses(*FIELD, *(error ? FIELD_ERROR : [])) }
          def form_field_input_code_cells_classes = { classes: klasses(*CELLS) }
          def form_field_input_code_cell_classes(error: false) = { classes: klasses(*CELL, *(error ? CELL_ERROR : [])) }
          def form_field_input_code_overlay_classes(**) = { classes: klasses(*OVERLAY) }
        end
      end
    end
  end
end
