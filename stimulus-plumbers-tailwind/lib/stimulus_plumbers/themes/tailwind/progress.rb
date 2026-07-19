# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Progress
        BAR = %w[
          relative w-full h-2 overflow-hidden rounded-full
          bg-(--sp-color-muted)
        ].freeze

        BAR_FILL = %w[
          h-full rounded-full bg-(--sp-color-primary)
          [.sp-progress-indeterminate_&]:animate-progress-slide
          [.sp-progress-indeterminate_&]:motion-reduce:animate-none
        ].freeze

        # Circle stroke/fill live in icons/customs/progress-ring.svg — @source never scans
        # .svg files, so Tailwind classes there are inert.
        # Indeterminate class and utility land on this same svg, so this needs the compound
        # [&.foo] form, not BAR_FILL's [.foo_&] descendant form.
        RING = %w[
          -rotate-90 text-(--sp-color-primary)
          [&.sp-progress-indeterminate]:animate-spin
        ].freeze

        METER = %w[
          w-full h-2 rounded-full
          [&::-webkit-meter-bar]:rounded-full [&::-webkit-meter-bar]:bg-(--sp-color-muted)
          [&::-webkit-meter-optimum-value]:bg-(--sp-color-success)
          [&::-webkit-meter-suboptimum-value]:bg-(--sp-color-warning)
          [&::-webkit-meter-even-less-good-value]:bg-(--sp-color-destructive)
          [&::-moz-meter-bar]:bg-(--sp-color-success)
        ].freeze

        private

        def progress_bar_classes
          { classes: klasses(*BAR) }
        end

        def progress_bar_fill_classes
          { classes: klasses(*BAR_FILL) }
        end

        def progress_ring_classes
          { classes: klasses(*RING) }
        end

        def progress_meter_classes
          { classes: klasses(*METER) }
        end
      end
    end
  end
end
