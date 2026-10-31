# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Form
        module CreditCard
          CELL = [*CharacterCells::CELL, "h-10", "min-w-16", "px-(--sp-space-2)"].freeze

          private

          def form_field_input_credit_card_classes(error: false, **)
            { classes: klasses(*CharacterCells::FIELD, *(error ? CharacterCells::FIELD_ERROR : [])) }
          end

          def form_field_input_credit_card_cells_classes(**)
            { classes: klasses(*CharacterCells::CELLS) }
          end

          def form_field_input_credit_card_cell_classes(error: false, **)
            { classes: klasses(*CELL, *(error ? CharacterCells::CELL_ERROR : [])) }
          end

          def form_field_input_credit_card_separator_classes(**)
            { classes: klasses(*CharacterCells::SEPARATOR) }
          end

          def form_field_input_credit_card_overlay_classes(**)
            { classes: klasses(*CharacterCells::OVERLAY) }
          end
        end
      end
    end
  end
end
