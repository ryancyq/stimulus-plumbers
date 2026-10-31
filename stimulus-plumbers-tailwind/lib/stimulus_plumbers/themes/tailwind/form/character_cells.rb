# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Form
        # Classes shared by the character-cell inputs: code and credit card.
        module CharacterCells
          FIELD = %w[
            relative inline-flex w-fit rounded-(--sp-radius-md)
            focus-within:ring-(length:--sp-focus-ring-width) focus-within:ring-(--sp-focus-ring-color)
            focus-within:ring-offset-(length:--sp-focus-ring-offset)
          ].freeze
          FIELD_ERROR = %w[focus-within:ring-(--sp-color-error)].freeze
          CELLS = %w[flex items-center gap-(--sp-space-1)].freeze
          CELL = %w[
            flex items-center justify-center rounded-(--sp-radius-md) border
            border-(--sp-color-muted-fg) bg-(--sp-color-bg)
            text-(length:--sp-text-lg) font-medium text-(--sp-color-fg)
            transition-colors
            data-[filled]:border-(--sp-color-fg)
            data-[caret]:border-(--sp-color-primary) data-[caret]:ring-1 data-[caret]:ring-(--sp-color-primary)
          ].freeze
          CELL_ERROR = %w[border-(--sp-color-error) data-[caret]:ring-(--sp-color-error)].freeze
          SEPARATOR = %w[text-(--sp-color-muted-fg)].freeze
          OVERLAY = %w[absolute inset-0 size-full cursor-text opacity-0 disabled:cursor-not-allowed].freeze
        end
      end
    end
  end
end
