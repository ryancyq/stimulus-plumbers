# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Card
        BASE = %w[
          rounded-(--sp-radius-md) border border-(--card-ring)
          bg-(--sp-color-bg) shadow-(--sp-shadow-xs)
        ].freeze

        VARIANTS = {
          primary:     %w[[--card-ring:var(--sp-color-primary)]].freeze,
          secondary:   %w[[--card-ring:var(--sp-color-secondary)]].freeze,
          tertiary:    %w[[--card-ring:var(--sp-color-muted-fg)]].freeze,
          success:     %w[[--card-ring:var(--sp-color-success)]].freeze,
          destructive: %w[[--card-ring:var(--sp-color-destructive)]].freeze,
          warning:     %w[[--card-ring:var(--sp-color-warning)]].freeze,
          info:        %w[[--card-ring:var(--sp-color-info)]].freeze
        }.freeze

        HEADER_BASE = %w[
          flex items-center gap-(--sp-space-3)
          px-(--sp-space-6) pt-(--sp-space-6)
        ].freeze

        ICON_BASE = %w[
          size-(--sp-space-6) shrink-0 stroke-current text-(--sp-color-muted-fg)
        ].freeze

        TITLE_BASE = %w[
          text-(length:--sp-text-base) font-semibold text-(--sp-color-fg)
        ].freeze

        BODY_BASE = %w[
          px-(--sp-space-6) pt-(--sp-space-3)
        ].freeze

        ACTION_BASE = %w[
          px-(--sp-space-6) pb-(--sp-space-6) pt-(--sp-space-4)
        ].freeze

        private

        def card_classes(variant: :tertiary)
          { classes: klasses(*VARIANTS.fetch(variant, VARIANTS[:tertiary]), *BASE) }
        end

        def card_header_classes  = { classes: klasses(*HEADER_BASE) }
        def card_icon_classes    = { classes: klasses(*ICON_BASE) }
        def card_title_classes   = { classes: klasses(*TITLE_BASE) }
        def card_body_classes    = { classes: klasses(*BODY_BASE) }
        def card_action_classes  = { classes: klasses(*ACTION_BASE) }
      end
    end
  end
end
