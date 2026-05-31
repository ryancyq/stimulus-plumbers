# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Layout
        DIVIDER_SEPARATOR = %w[border-t border-(--sp-color-border) my-(--sp-space-1)].freeze
        DIVIDER           = %w[flex items-center gap-(--sp-space-3)].freeze
        DIVIDER_LABEL     = %w[text-(length:--sp-text-sm) text-(--sp-color-fg-muted) whitespace-nowrap font-medium].freeze
        POPOVER_WRAPPER = %w[relative inline-block].freeze
        POPOVER_TRIGGER = %w[
          inline-flex items-center justify-center gap-(--sp-space-2) font-medium
          rounded-(--sp-radius-md) transition-colors
          focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2
          focus-visible:ring-(--sp-focus-ring-color)
          disabled:pointer-events-none disabled:opacity-50
          border border-(--sp-color-border) bg-transparent text-(--sp-color-fg)
          hover:bg-(--sp-color-muted)
          h-9 px-(--sp-space-4) py-(--sp-space-2) text-(length:--sp-text-sm)
        ].freeze
        POPOVER = %w[
          rounded-(--sp-radius-md) border border-(--sp-color-border)
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

        def popover_wrapper_classes
          { classes: klasses(*POPOVER_WRAPPER) }
        end

        def popover_trigger_classes
          { classes: klasses(*POPOVER_TRIGGER) }
        end

        def popover_classes
          { classes: klasses(*POPOVER) }
        end
      end
    end
  end
end
