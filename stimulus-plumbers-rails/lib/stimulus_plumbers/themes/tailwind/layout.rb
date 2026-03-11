# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Layout
        DIVIDER = %w[border-t border-[--sp-color-border] my-[--sp-space-1]].freeze
        POPOVER = %w[
          rounded-[--sp-radius-lg] border border-[--sp-color-border]
          bg-[--sp-color-bg] shadow-[--sp-shadow-md] z-[--sp-z-popover]
        ].freeze

        private

        def divider_classes
          { classes: klasses(*DIVIDER) }
        end

        def popover_classes
          { classes: klasses(*POPOVER) }
        end
      end
    end
  end
end
