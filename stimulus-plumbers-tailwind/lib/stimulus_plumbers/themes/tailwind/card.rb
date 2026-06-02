# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Card
        BASE = %w[
          rounded-(--sp-radius-md) border border-(--sp-color-border)
          bg-(--sp-color-bg) shadow-(--sp-shadow-xs)
        ].freeze

        SECTION_BASE = %w[
          p-(--sp-space-6)
          [&:not(:first-child)]:border-t
          [&:not(:first-child)]:border-(--sp-color-border)
        ].freeze

        private

        def card_classes
          { classes: klasses(*BASE) }
        end

        def card_section_classes
          { classes: klasses(*SECTION_BASE) }
        end
      end
    end
  end
end
