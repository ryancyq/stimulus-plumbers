# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Link
        VARIANTS = {
          default:     %w[
            [--link-color:var(--sp-color-primary)]
            [--link-ring:var(--sp-color-primary)]
          ].freeze,
          success:     %w[
            [--link-color:var(--sp-color-success)]
            [--link-ring:var(--sp-color-success-ring)]
          ].freeze,
          destructive: %w[
            [--link-color:var(--sp-color-destructive)]
            [--link-ring:var(--sp-color-destructive)]
          ].freeze,
          warning:     %w[
            [--link-color:var(--sp-color-warning)]
            [--link-ring:var(--sp-color-warning-ring)]
          ].freeze,
          info:        %w[
            [--link-color:var(--sp-color-info)]
            [--link-ring:var(--sp-color-info-ring)]
          ].freeze
        }.freeze

        BASE = %w[
          inline-flex items-center gap-(--sp-space-1)
          font-medium text-(--link-color)
          hover:underline
          focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2
          focus-visible:ring-(--link-ring)
        ].freeze

        private

        def link_classes(variant: :default)
          {
            classes: klasses(
              *BASE,
              *VARIANTS.fetch(variant, VARIANTS[:default])
            )
          }
        end

        def link_icon_classes
          { classes: klasses("size-(--sp-control-size)", "stroke-current") }
        end
      end
    end
  end
end
