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

        BUTTON = [
          *Control::BASE,
          "inline-flex items-center justify-center gap-(--sp-space-2)",
          "rounded-(--sp-radius-md)",
          "h-9 px-(--sp-space-4) text-(length:--sp-text-base)",
          "bg-(--sp-color-bg-muted) text-(--link-bg)",
          "border border-(--link-bg)/40",
          "hover:bg-(--link-bg)/10 hover:text-(--link-bg) hover:border-(--link-bg)/60",
          "focus-visible:ring-(--link-ring)"
        ].freeze

        CARD = [
          *Control::BASE,
          *Card::BASE,
          *Button::CARD,
          "text-(--sp-color-muted-fg)",
          "hover:bg-(--sp-color-muted) hover:border-(--sp-color-border-strong) hover:text-(--sp-color-fg)",
          "focus-visible:ring-(--card-ring)"
        ].freeze

        private

        def link_classes(type: :default, variant: :default)
          case type
          when :button then { classes: klasses(*BUTTON, *VARIANTS.fetch(variant, VARIANTS[:default])) }
          when :card   then { classes: klasses(*CARD, *Card::VARIANTS.fetch(variant, Card::VARIANTS[:default])) }
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
