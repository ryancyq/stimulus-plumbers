# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Layout
        DIVIDER_SEPARATOR = %w[border-t border-(--sp-color-border) my-(--sp-space-1)].freeze
        DIVIDER           = %w[flex items-center gap-(--sp-space-3)].freeze
        DIVIDER_LABEL     = %w[text-(length:--sp-text-sm) text-(--sp-color-fg-muted) whitespace-nowrap font-medium].freeze
        POPOVER = %w[
          rounded-(--sp-radius-lg) border border-(--sp-color-border)
          bg-(--sp-color-bg) shadow-(--sp-shadow-md) z-(--sp-z-popover)
        ].freeze

        private

        def divider_classes
          { classes: klasses(*DIVIDER) }
        end

        def divider_separator_classes
          { classes: klasses(*DIVIDER_SEPARATOR) }
        end

        def divider_label_classes
          { classes: klasses(*DIVIDER_LABEL) }
        end

        def popover_classes
          { classes: klasses(*POPOVER) }
        end
      end
    end
  end
end
