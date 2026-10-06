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
          sp-popover
          rounded-(--sp-radius-md) border border-(--sp-color-border)
          bg-(--sp-color-bg) shadow-(--sp-shadow-md) z-(--sp-z-popover)
          [position:fixed] [position-anchor:auto] [inset:auto] m-0
          [max-inline-size:min(90vi,32rem)] [max-block-size:min(80vb,32rem)] overflow-auto
        ].freeze

        POPOVER_PLACEMENTS = {
          block_end_start:   %w[[position-area:block-end_span-inline-end] [position-try-fallbacks:flip-block,flip-inline]],
          block_end:         %w[[position-area:block-end] [position-try-fallbacks:flip-block]],
          block_end_end:     %w[[position-area:block-end_span-inline-start] [position-try-fallbacks:flip-block,flip-inline]],
          block_start_start: %w[[position-area:block-start_span-inline-end] [position-try-fallbacks:flip-block,flip-inline]],
          block_start:       %w[[position-area:block-start] [position-try-fallbacks:flip-block]],
          block_start_end:   %w[[position-area:block-start_span-inline-start] [position-try-fallbacks:flip-block,flip-inline]],
          inline_start:      %w[[position-area:inline-start] [position-try-fallbacks:flip-inline]],
          inline_end:        %w[[position-area:inline-end] [position-try-fallbacks:flip-inline]]
        }.freeze

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

        def popover_classes(placement: :block_end_start)
          { classes: klasses(*POPOVER, *POPOVER_PLACEMENTS.fetch(placement, POPOVER_PLACEMENTS[:block_end_start])) }
        end
      end
    end
  end
end
