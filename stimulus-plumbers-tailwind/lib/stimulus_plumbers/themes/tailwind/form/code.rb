# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Form
        module Code
          CELL = [*CharacterCells::CELL, "size-10", "data-[group-end]:me-(--sp-space-2)"].freeze

          private

          def form_field_input_code_classes(error: false, **)
            { classes: class_names(*CharacterCells::FIELD, *(error ? CharacterCells::FIELD_ERROR : [])) }
          end

          def form_field_input_code_cells_classes(**)
            { classes: class_names(*CharacterCells::CELLS) }
          end

          def form_field_input_code_cell_classes(error: false, **)
            { classes: class_names(*CELL, *(error ? CharacterCells::CELL_ERROR : [])) }
          end

          def form_field_input_code_separator_classes(**)
            { classes: class_names(*CharacterCells::SEPARATOR) }
          end

          def form_field_input_code_overlay_classes(**)
            { classes: class_names(*CharacterCells::OVERLAY) }
          end
        end
      end
    end
  end
end
