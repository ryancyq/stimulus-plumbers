# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Card
        BASE = %w[
          rounded-(--sp-radius-md) border border-(--sp-color-border)
          bg-(--sp-color-bg) shadow-(--sp-shadow-xs)
        ].freeze

        VARIANTS = {
          default:     %w[[--card-ring:var(--sp-color-primary)]].freeze,
          success:     %w[[--card-ring:var(--sp-color-success)]].freeze,
          destructive: %w[[--card-ring:var(--sp-color-destructive)]].freeze,
          warning:     %w[[--card-ring:var(--sp-color-warning)]].freeze,
          info:        %w[[--card-ring:var(--sp-color-info)]].freeze
        }.freeze

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
