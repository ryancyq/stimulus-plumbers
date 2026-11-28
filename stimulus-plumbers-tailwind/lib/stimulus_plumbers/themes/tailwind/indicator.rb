# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Indicator
        VARIANTS = {
          primary:     "bg-(--sp-color-primary)",
          secondary:   "bg-(--sp-color-secondary)",
          tertiary:    "bg-(--sp-color-muted-fg)",
          success:     "bg-(--sp-color-success)",
          destructive: "bg-(--sp-color-destructive)",
          warning:     "bg-(--sp-color-warning)",
          info:        "bg-(--sp-color-info)"
        }.freeze

        DOT   = %w[inline-flex size-2.5 rounded-full].freeze
        BADGE = %w[
          inline-flex items-center justify-center
          min-w-5 h-5 px-1
          rounded-full text-(length:--sp-text-xs) font-medium text-white
        ].freeze

        # Positioning context for the pulse ring.
        CONTAINER = %w[relative inline-flex items-center justify-center].freeze

        PULSE_RING = %w[
          absolute inset-0 rounded-full
          bg-(--sp-color-indicator) opacity-75
          animate-ping motion-reduce:animate-none
        ].freeze

        private

        def indicator_classes(type: :dot, variant: nil)
          { classes: class_names(*(type.to_sym == :badge ? BADGE : DOT), VARIANTS.fetch(variant, nil)) }
        end

        def indicator_container_classes
          { classes: class_names(*CONTAINER) }
        end

        def indicator_pulse_classes
          { classes: class_names(*PULSE_RING) }
        end
      end
    end
  end
end
