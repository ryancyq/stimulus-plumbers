# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Link
        VARIANTS = {
          default:     %w[
            [--link-color:var(--sp-color-primary)]
            [--link-ring:var(--sp-color-primary)]
            [--link-bg:var(--sp-color-primary)]
          ].freeze,
          success:     %w[
            [--link-color:var(--sp-color-success)]
            [--link-ring:var(--sp-color-success-ring)]
            [--link-bg:var(--sp-color-success)]
          ].freeze,
          destructive: %w[
            [--link-color:var(--sp-color-destructive)]
            [--link-ring:var(--sp-color-destructive)]
            [--link-bg:var(--sp-color-destructive)]
          ].freeze,
          warning:     %w[
            [--link-color:var(--sp-color-warning)]
            [--link-ring:var(--sp-color-warning-ring)]
            [--link-bg:var(--sp-color-warning)]
          ].freeze,
          info:        %w[
            [--link-color:var(--sp-color-info)]
            [--link-ring:var(--sp-color-info-ring)]
            [--link-bg:var(--sp-color-info)]
          ].freeze
        }.freeze

        BASE = %w[
          inline-flex items-center gap-(--sp-space-1)
          font-medium text-(--link-color)
          hover:underline
          focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2
          focus-visible:ring-(--link-ring)
        ].freeze

        BUTTON_TYPE_BASE = %w[
          inline-flex items-center justify-center gap-(--sp-space-2) font-medium
          rounded-(--sp-radius-md) transition-colors
          h-9 px-(--sp-space-4) text-(length:--sp-text-base)
          bg-(--sp-color-bg-muted) text-(--link-bg)
          border border-(--link-bg)/40
          hover:bg-(--link-bg)/10 hover:text-(--link-bg) hover:border-(--link-bg)/60
          focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2
          focus-visible:ring-(--link-ring)
          disabled:pointer-events-none disabled:opacity-50
        ].freeze

        CARD_TYPE_BASE = %w[
          inline-flex justify-between items-center flex-1 gap-(--sp-space-3) p-(--sp-space-4)
          font-medium rounded-(--sp-radius-md) transition-colors
          bg-(--sp-color-bg) text-(--sp-color-muted-fg)
          border border-(--sp-color-border) shadow-(--sp-shadow-xs)
          hover:bg-(--sp-color-muted) hover:border-(--sp-color-border-strong) hover:text-(--sp-color-fg)
          focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2
          focus-visible:ring-(--card-ring)
          disabled:pointer-events-none disabled:opacity-50
        ].freeze

        CARD_VARIANTS = {
          default:     %w[[--card-ring:var(--sp-color-primary)]].freeze,
          success:     %w[[--card-ring:var(--sp-color-success)]].freeze,
          destructive: %w[[--card-ring:var(--sp-color-destructive)]].freeze,
          warning:     %w[[--card-ring:var(--sp-color-warning)]].freeze,
          info:        %w[[--card-ring:var(--sp-color-info)]].freeze
        }.freeze

        private

        def link_classes(type: :default, variant: :default)
          case type
          when :button then { classes: klasses(*BUTTON_TYPE_BASE, *VARIANTS.fetch(variant, VARIANTS[:default])) }
          when :card   then { classes: klasses(*CARD_TYPE_BASE, *CARD_VARIANTS.fetch(variant, CARD_VARIANTS[:default])) }
          else              { classes: klasses(*BASE, *VARIANTS.fetch(variant, VARIANTS[:default])) }
          end
        end

        def link_icon_classes
          { classes: klasses("size-(--sp-control-size)", "stroke-current") }
        end
      end
    end
  end
end
