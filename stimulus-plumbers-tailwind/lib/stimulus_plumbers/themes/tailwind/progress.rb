# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Progress
        BAR = %w[
          relative w-full overflow-hidden rounded-full
          bg-(--sp-color-muted)
        ].freeze

        BAR_HEIGHTS = { false => "h-2", true => "h-5" }.freeze

        # tabular-nums so the readout doesn't jitter as digits change under a drag.
        VALUE_TEXT = %w[text-xs font-medium leading-none tabular-nums].freeze

        # Centered over the track, sized to its text, on an opaque pill: neither fg nor primary-fg
        # clears AA over both the muted track and the primary fill, so the readout brings its own
        # background instead of blending with whatever sits under it.
        BAR_VALUE = [
          *VALUE_TEXT,
          "absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2",
          "px-(--sp-space-1) rounded-full",
          "bg-(--sp-color-bg) text-(--sp-color-fg)"
        ].freeze

        # `data-intent` (set per-segment by a ramp) overrides the default primary fill color.
        BAR_FILL = %w[
          h-full rounded-full bg-(--sp-color-primary)
          [&[data-intent=danger]]:bg-(--sp-color-destructive)
          [&[data-intent=warning]]:bg-(--sp-color-warning)
          [&[data-intent=success]]:bg-(--sp-color-success)
          [.sp-progress-indeterminate_&]:animate-progress-slide
          [.sp-progress-indeterminate_&]:motion-reduce:animate-none
        ].freeze

        # Row of equal-width slots; each slot is its own track with a BAR_FILL inside.
        SEGMENTED = %w[flex w-full gap-(--sp-space-1)].freeze

        SEGMENT = %w[
          flex-1 h-2 overflow-hidden rounded-full
          bg-(--sp-color-muted)
        ].freeze

        # Circle stroke/fill live in icons/customs/progress-ring.svg — @source never scans
        # .svg files, so Tailwind classes there are inert.
        # Indeterminate class and utility land on this same svg, so this needs the compound
        # [&.foo] form, not BAR_FILL's [.foo_&] descendant form.
        RING = %w[
          -rotate-90 text-(--sp-color-primary)
          [&.sp-progress-indeterminate]:animate-spin
        ].freeze

        RING_SIZES = { sm: "size-8", md: "size-12", lg: "size-16" }.freeze

        METER = %w[
          w-full h-2 rounded-full
          [&::-webkit-meter-bar]:rounded-full [&::-webkit-meter-bar]:bg-(--sp-color-muted)
          [&::-webkit-meter-optimum-value]:bg-(--sp-color-success)
          [&::-webkit-meter-suboptimum-value]:bg-(--sp-color-warning)
          [&::-webkit-meter-even-less-good-value]:bg-(--sp-color-destructive)
          [&::-moz-meter-bar]:bg-(--sp-color-success)
        ].freeze

        private

        def progress_bar_classes(labelled: false)
          { classes: klasses(*BAR, BAR_HEIGHTS.fetch(labelled)) }
        end

        def progress_bar_value_classes
          { classes: klasses(*BAR_VALUE) }
        end

        def progress_bar_fill_classes
          { classes: klasses(*BAR_FILL) }
        end

        def progress_segmented_classes
          { classes: klasses(*SEGMENTED) }
        end

        def progress_segment_classes
          { classes: klasses(*SEGMENT) }
        end

        def progress_ring_classes(size: nil)
          { classes: klasses(*RING, *Array(RING_SIZES[size])) }
        end

        def progress_meter_classes
          { classes: klasses(*METER) }
        end
      end
    end
  end
end
