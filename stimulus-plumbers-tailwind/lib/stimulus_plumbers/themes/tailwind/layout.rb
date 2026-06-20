# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Layout
        # ── Divider ───────────────────────────────────────────────────────────
        DIVIDER           = %w[w-full flex items-center gap-(--sp-space-3)].freeze
        DIVIDER_SEPARATOR = %w[flex-1 h-px bg-(--sp-color-border) border-0].freeze
        DIVIDER_LABEL     = %w[text-(length:--sp-text-sm) text-(--sp-color-muted-fg) whitespace-nowrap font-medium].freeze

        # ── Popover ───────────────────────────────────────────────────────────
        POPOVER_WRAPPER = %w[relative inline-block].freeze
        POPOVER_TRIGGER = [
          *Control::BASE,
          "inline-flex items-center justify-center gap-(--sp-space-2)",
          "rounded-(--sp-radius-md)",
          "focus-visible:ring-(--sp-focus-ring-color)",
          "border border-(--sp-color-border) bg-transparent text-(--sp-color-fg)",
          "hover:bg-(--sp-color-muted)",
          "h-9 px-(--sp-space-4) py-(--sp-space-2) text-(length:--sp-text-sm)"
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
