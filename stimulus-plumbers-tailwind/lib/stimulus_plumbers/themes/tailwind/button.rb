# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Button
        # Variant sets --btn-bg/fg/ring CSS variables; type references them.
        VARIANTS = {
          default:     %w[
            [--btn-bg:var(--sp-color-primary)]
            [--btn-fg:var(--sp-color-primary-fg)]
            [--btn-ring:var(--sp-color-primary)]
          ].freeze,
          success:     %w[
            [--btn-bg:var(--sp-color-success)]
            [--btn-fg:var(--sp-color-success-fg)]
            [--btn-ring:var(--sp-color-success-ring)]
          ].freeze,
          destructive: %w[
            [--btn-bg:var(--sp-color-destructive)]
            [--btn-fg:var(--sp-color-destructive-fg)]
            [--btn-ring:var(--sp-color-destructive)]
          ].freeze,
          warning:     %w[
            [--btn-bg:var(--sp-color-warning)]
            [--btn-fg:var(--sp-color-warning-fg)]
            [--btn-ring:var(--sp-color-warning-ring)]
          ].freeze,
          info:        %w[
            [--btn-bg:var(--sp-color-info)]
            [--btn-fg:var(--sp-color-info-fg)]
            [--btn-ring:var(--sp-color-info-ring)]
          ].freeze
        }.freeze

        TYPES = {
          # ── Filled ────────────────────────────────────────────────────────
          primary:   %w[
            bg-(--btn-bg) text-(--btn-fg)
            border border-transparent
            hover:bg-(--btn-bg)/90
            focus-visible:ring-(--btn-ring)
          ].freeze,
          secondary: %w[
            bg-(--btn-bg)/15 text-(--btn-bg)
            border border-(--btn-bg)/25
            hover:bg-(--btn-bg)/25
            focus-visible:ring-(--btn-ring)
          ].freeze,
          tertiary:  %w[
            bg-(--sp-color-bg) text-(--btn-bg)
            border border-(--btn-bg)/40
            hover:bg-(--btn-bg)/10
            focus-visible:ring-(--btn-ring)
          ].freeze,
          # ── Outline ───────────────────────────────────────────────────────
          outline:   %w[
            bg-(--sp-color-bg) text-(--btn-bg)
            border border-(--btn-bg)
            hover:bg-(--btn-bg) hover:text-(--btn-fg)
            focus-visible:ring-(--btn-ring)
          ].freeze,
          # ── Special ───────────────────────────────────────────────────────
          ghost:     %w[
            bg-transparent text-(--btn-bg)
            border border-transparent
            hover:bg-(--btn-bg)/10
            focus-visible:ring-(--btn-ring)
          ].freeze,
          fab:       %w[
            rounded-full shadow-lg
            bg-(--btn-bg) text-(--btn-fg)
            border border-transparent
            hover:bg-(--btn-bg)/90 hover:shadow-xl
            focus-visible:ring-(--btn-ring)
          ].freeze,
          dashed:    %w[
            bg-transparent text-(--btn-bg)
            border border-dashed border-(--btn-bg)/60
            hover:bg-(--btn-bg)/10
            focus-visible:ring-(--btn-ring)
          ].freeze
        }.freeze

        SIZES = {
          xs: %w[h-7 px-(--sp-space-2) text-(length:--sp-text-xs)].freeze,
          sm: %w[h-8 px-(--sp-space-3) text-(length:--sp-text-sm)].freeze,
          md: %w[h-9 px-(--sp-space-4) text-(length:--sp-text-base)].freeze,
          lg: %w[h-11 px-(--sp-space-6) text-(length:--sp-text-lg)].freeze,
          xl: %w[h-14 px-(--sp-space-6) text-(length:--sp-text-lg)].freeze
        }.freeze

        FLEX_ALIGN = {
          row: {
            left:   "justify-start",
            center: %w[justify-center items-center].freeze,
            right:  "justify-end",
            top:    "items-start",
            bottom: "items-end"
          }.freeze,
          col: {
            top:    "justify-start",
            center: %w[justify-center items-center].freeze,
            bottom: "justify-end",
            left:   "items-start",
            right:  "items-end"
          }.freeze
        }.freeze

        BUTTON_LINK_BASE = %w[
          inline-flex items-center justify-center gap-(--sp-space-2) font-medium
          rounded-(--sp-radius-md) transition-colors
          bg-(--sp-color-bg-muted) text-(--sp-color-fg)
          border border-(--sp-color-border)
          hover:bg-(--sp-color-muted) hover:text-(--sp-color-fg) hover:border-(--sp-color-fg-muted)
          focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2
          focus-visible:ring-(--btn-ring)
          disabled:pointer-events-none disabled:opacity-50
        ].freeze

        BASE = %w[
          inline-flex items-center justify-center gap-(--sp-space-2) font-medium
          rounded-(--sp-radius-md) transition-colors
          focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2
          disabled:pointer-events-none disabled:opacity-50
          [.sp-button-group_&]:rounded-none
          [.sp-button-group_&:first-child]:rounded-s-(--sp-radius-md)
          [.sp-button-group_&:last-child]:rounded-e-(--sp-radius-md)
        ].freeze

        GROUP_BASE = %w[
          sp-button-group
          inline-flex shadow-(--sp-shadow-xs)
          [&>*:not(:first-child)]:-ml-px
        ].freeze

        private

        def button_classes(type: :primary, variant: :default, size: :md)
          {
            classes: klasses(
              *BASE,
              *VARIANTS.fetch(variant, VARIANTS[:default]),
              *TYPES.fetch(type, TYPES[:primary]),
              *SIZES.fetch(size, [])
            )
          }
        end

        def button_group_classes(alignment: :left, direction: :row)
          {
            classes: klasses(
              *GROUP_BASE,
              *Array(FLEX_ALIGN.dig(direction, alignment))
            )
          }
        end

        def button_icon_classes
          { classes: klasses("size-(--sp-control-size)", "stroke-current") }
        end

        def button_link_classes(variant: :default, size: :md)
          {
            classes: klasses(
              *BUTTON_LINK_BASE,
              *VARIANTS.fetch(variant, VARIANTS[:default]),
              *SIZES.fetch(size, [])
            )
          }
        end
      end
    end
  end
end
