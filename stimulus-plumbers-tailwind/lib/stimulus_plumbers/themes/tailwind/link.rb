# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Link
        # ── Type styles ───────────────────────────────────────────────────────
        BASE = [
          *Control::BASE,
          "inline-flex items-center gap-(--sp-space-1)",
          "text-(--link-color)",
          "hover:underline",
          "focus-visible:ring-(--link-ring)"
        ].freeze

        BUTTON = [
          *Control::BASE,
          "whitespace-nowrap",
          "inline-flex items-center justify-center gap-(--sp-space-2)",
          "h-9 px-(--sp-space-4) text-(length:--sp-text-base)",
          "[&:not(:has(>span))]:aspect-square",
          "[&:not(:has(>span))]:px-0",
          "rounded-(--sp-radius-md)",
          "bg-(--sp-color-bg) text-(--link-color)",
          "border border-(--link-color)",
          "hover:bg-(--link-bg)/10",
          "focus-visible:ring-(--link-ring)"
        ].freeze

        CARD = [
          *Control::BASE,
          "whitespace-nowrap",
          *Button::CARD,
          "rounded-(--sp-radius-md)",
          "bg-(--sp-color-bg) text-(--link-color)",
          "border border-(--link-color) shadow-(--sp-shadow-xs)",
          "hover:bg-(--link-bg)/10",
          "focus-visible:ring-(--link-ring)"
        ].freeze

        # ── Color tokens ──────────────────────────────────────────────────────
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

        private

        def link_classes(type: :default, variant: :default)
          variant_classes = VARIANTS.fetch(variant, VARIANTS[:default])
          case type
          when :button then { classes: klasses(*BUTTON, *variant_classes) }
          when :card   then { classes: klasses(*CARD, *variant_classes) }
          else              { classes: klasses(*BASE, *variant_classes) }
          end
        end

        def link_icon_classes
          { classes: klasses("stroke-current") }
        end
      end
    end
  end
end
