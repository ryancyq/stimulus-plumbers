# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Card
        BASE = %w[
          flex flex-col
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

        HEADER = %w[
          flex items-center gap-(--sp-space-3)
          px-(--sp-space-6) py-(--sp-space-6)
        ].freeze

        ICON = %w[
          shrink-0 stroke-current text-(--sp-color-muted-fg)
        ].freeze

        TITLE = %w[
          text-(length:--sp-text-base) font-semibold text-(--sp-color-fg)
        ].freeze

        BODY = %w[
          px-(--sp-space-6) py-(--sp-space-3)
        ].freeze

        ACTION = %w[w-full justify-start].freeze

        private

        def card_classes(variant: :tertiary)
          { classes: klasses(*VARIANTS.fetch(variant, VARIANTS[:tertiary]), *BASE) }
        end

        def card_header_classes
          { classes: klasses(*HEADER) }
        end

        def card_icon_classes
          { classes: klasses(*ICON) }
        end

        def card_title_classes
          { classes: klasses(*TITLE) }
        end

        def card_body_classes
          { classes: klasses(*BODY) }
        end

        def card_action_classes
          { classes: klasses(*ACTION) }
        end
      end
    end
  end
end
