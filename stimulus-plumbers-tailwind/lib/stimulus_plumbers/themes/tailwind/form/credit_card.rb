# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Form
        module CreditCard
          CREDIT_CARD_FIELD = %w[
            relative inline-flex w-fit rounded-(--sp-radius-md)
            focus-within:ring-(length:--sp-focus-ring-width) focus-within:ring-(--sp-focus-ring-color)
            focus-within:ring-offset-(length:--sp-focus-ring-offset)
          ].freeze
          CREDIT_CARD_FIELD_ERROR = %w[focus-within:ring-(--sp-color-error)].freeze
          CREDIT_CARD_CELLS = %w[flex items-center gap-(--sp-space-1)].freeze
          CREDIT_CARD_CELL = %w[
            flex h-10 min-w-16 items-center justify-center px-(--sp-space-2)
            rounded-(--sp-radius-md) border
            border-(--sp-color-muted-fg) bg-(--sp-color-bg)
            text-(length:--sp-text-lg) font-medium text-(--sp-color-fg)
            transition-colors
            data-[filled]:border-(--sp-color-fg)
            data-[caret]:border-(--sp-color-primary) data-[caret]:ring-1 data-[caret]:ring-(--sp-color-primary)
          ].freeze
          CREDIT_CARD_CELL_ERROR = %w[border-(--sp-color-error) data-[caret]:ring-(--sp-color-error)].freeze
          CREDIT_CARD_SEPARATOR = %w[text-(--sp-color-muted-fg)].freeze
          CREDIT_CARD_OVERLAY = %w[absolute inset-0 size-full cursor-text opacity-0 disabled:cursor-not-allowed].freeze

          private

          def form_field_input_credit_card_classes(error: false, **)
            { classes: klasses(*CREDIT_CARD_FIELD, *(error ? CREDIT_CARD_FIELD_ERROR : [])) }
          end

          def form_field_input_credit_card_cells_classes(**)
            { classes: klasses(*CREDIT_CARD_CELLS) }
          end

          def form_field_input_credit_card_cell_classes(error: false, **)
            { classes: klasses(*CREDIT_CARD_CELL, *(error ? CREDIT_CARD_CELL_ERROR : [])) }
          end

          def form_field_input_credit_card_separator_classes(**)
            { classes: klasses(*CREDIT_CARD_SEPARATOR) }
          end

          def form_field_input_credit_card_overlay_classes(**)
            { classes: klasses(*CREDIT_CARD_OVERLAY) }
          end
        end
      end
    end
  end
end
