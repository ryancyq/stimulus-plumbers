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

        # Row wrapper for an outside readout — the track shrinks to leave room for the text.
        BAR_GROUP = %w[flex w-full items-center gap-(--sp-space-2)].freeze

        # Clipped to the glyphs, this paints primary-fg up to the fill edge and fg past it, so the
        # digits split rather than sit on a pill — neither color alone clears AA over both. The
        # edge is --sp-progress-percent (set by the progress controller), 0 until it connects.
        # Must stay on one line: Tailwind scans source text, so a class split across a string
        # continuation or interpolation never appears contiguously and is silently dropped.
        # rubocop:disable-next Layout/LineLength
        BAR_VALUE_SPLIT = "bg-[linear-gradient(to_right,var(--sp-color-primary-fg)_0_calc(var(--sp-progress-percent,0)*1%),var(--sp-color-fg)_0)]"

        # Spans the track so the gradient's coordinates are the track's.
        BAR_VALUE = [
          *VALUE_TEXT,
          "absolute inset-x-0 top-1/2 -translate-y-1/2 text-center pointer-events-none",
          BAR_VALUE_SPLIT,
          "bg-clip-text [-webkit-background-clip:text] text-transparent"
        ].freeze

        # Beside the track it never sits over the fill, so it needs no pill.
        BAR_VALUE_OUTSIDE = [*VALUE_TEXT, "shrink-0 text-(--sp-color-primary)"].freeze

        # `data-intent` (set per-segment by a ramp) overrides the default primary fill color.
        FILL_BASE = %w[
          h-full rounded-full bg-(--sp-color-primary)
          [&[data-intent=danger]]:bg-(--sp-color-destructive)
          [&[data-intent=warning]]:bg-(--sp-color-warning)
          [&[data-intent=success]]:bg-(--sp-color-success)
        ].freeze

        # animations.css renames a slot fill's keyframes but reads iteration-count off this.
        FILL_INDETERMINATE = %w[
          [.sp-progress-indeterminate_&]:animate-progress-slide
          [.sp-progress-indeterminate_&]:motion-reduce:animate-none
        ].freeze

        BAR_FILL = [*FILL_BASE, *FILL_INDETERMINATE].freeze

        # Row of equal-width slots; each slot is its own track with a SEGMENT_FILL inside.
        SEGMENT_GROUP = %w[flex w-full gap-(--sp-space-1)].freeze

        SEGMENT = %w[
          flex-1 h-2 overflow-hidden rounded-full
          bg-(--sp-color-muted)
        ].freeze

        # Separate key so a theme can restyle a slot's chunk without touching the bar's.
        SEGMENT_FILL = [*FILL_BASE, *FILL_INDETERMINATE].freeze

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

        def progress_bar_group_classes
          { classes: klasses(*BAR_GROUP) }
        end

        def progress_bar_value_classes
          { classes: klasses(*BAR_VALUE) }
        end

        def progress_bar_value_outside_classes
          { classes: klasses(*BAR_VALUE_OUTSIDE) }
        end

        def progress_bar_fill_classes
          { classes: klasses(*BAR_FILL) }
        end

        def progress_segment_group_classes
          { classes: klasses(*SEGMENT_GROUP) }
        end

        def progress_segment_classes
          { classes: klasses(*SEGMENT) }
        end

        def progress_segment_fill_classes
          { classes: klasses(*SEGMENT_FILL) }
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
