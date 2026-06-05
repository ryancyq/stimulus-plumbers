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
          primary:     %w[
            bg-(--btn-bg) text-(--btn-fg)
            border border-transparent
            hover:bg-(--btn-bg)/90
            focus-visible:ring-(--btn-ring)
          ].freeze,
          secondary:   %w[
            bg-(--btn-bg)/15 text-(--btn-bg)
            border border-(--btn-bg)/25
            hover:bg-(--btn-bg)/25
            focus-visible:ring-(--btn-ring)
          ].freeze,
          tertiary:    %w[
            bg-(--sp-color-bg) text-(--btn-bg)
            border border-(--btn-bg)/40
            hover:bg-(--btn-bg)/10
            focus-visible:ring-(--btn-ring)
          ].freeze,
          # ── Outline ───────────────────────────────────────────────────────
          outline:     %w[
            bg-(--sp-color-bg) text-(--btn-bg)
            border border-(--btn-bg)
            hover:bg-(--btn-bg) hover:text-(--btn-fg)
            focus-visible:ring-(--btn-ring)
          ].freeze,
          # ── Special ───────────────────────────────────────────────────────
          ghost:       %w[
            bg-transparent text-(--btn-bg)
            border border-transparent
            hover:bg-(--btn-bg)/10
            focus-visible:ring-(--btn-ring)
          ].freeze,
          fab:         %w[
            rounded-full shadow-lg
            bg-(--btn-bg) text-(--btn-fg)
            border border-transparent
            hover:bg-(--btn-bg)/90 hover:shadow-xl
            focus-visible:ring-(--btn-ring)
          ].freeze,
          fab_outline: %w[
            rounded-full shadow-lg
            bg-(--sp-color-bg) text-(--btn-bg)
            border border-(--btn-bg)
            hover:bg-(--btn-bg) hover:text-(--btn-fg) hover:shadow-xl
            focus-visible:ring-(--btn-ring)
          ].freeze,
          dashed:      %w[
            bg-transparent text-(--btn-bg)
            border border-dashed border-(--btn-bg)/60
            hover:bg-(--btn-bg)/10
            focus-visible:ring-(--btn-ring)
          ].freeze,
          # ── Card ──────────────────────────────────────────────────────────
          card:        %w[
            bg-(--sp-color-bg) text-(--sp-color-muted-fg)
            border border-(--sp-color-border) shadow-(--sp-shadow-xs)
            hover:bg-(--sp-color-muted) hover:border-(--sp-color-border-strong) hover:text-(--sp-color-fg)
            focus-visible:ring-(--card-ring)
          ].freeze
        }.freeze

        CARD_SIZE = %w[
          inline-flex justify-start items-center flex-1 gap-(--sp-space-3) p-(--sp-space-4)
          [&>:last-child:not(:first-child)]:ml-auto
        ].freeze

        CARD_VARIANTS = {
          default:     %w[[--card-ring:var(--sp-color-primary)]].freeze,
          success:     %w[[--card-ring:var(--sp-color-success)]].freeze,
          destructive: %w[[--card-ring:var(--sp-color-destructive)]].freeze,
          warning:     %w[[--card-ring:var(--sp-color-warning)]].freeze,
          info:        %w[[--card-ring:var(--sp-color-info)]].freeze
        }.freeze

        SIZES = {
          xs: %w[h-7 px-(--sp-space-2) text-(length:--sp-text-xs)].freeze,
          sm: %w[h-8 px-(--sp-space-3) text-(length:--sp-text-sm)].freeze,
          md: %w[h-9 px-(--sp-space-4) text-(length:--sp-text-base)].freeze,
          lg: %w[h-11 px-(--sp-space-6) text-(length:--sp-text-lg)].freeze,
          xl: %w[h-14 px-(--sp-space-6) text-(length:--sp-text-lg)].freeze
        }.freeze

        BASE_SHARED = %w[
          font-medium whitespace-nowrap rounded-(--sp-radius-md) transition-colors
          focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2
          disabled:pointer-events-none disabled:opacity-50
          [.sp-button-group_&]:rounded-none
          [.sp-button-group_&:first-child]:rounded-s-(--sp-radius-md)
          [.sp-button-group_&:last-child]:rounded-e-(--sp-radius-md)
          [.sp-button-group-stacked_&]:rounded-none
          [.sp-button-group-stacked_&:first-child]:rounded-t-(--sp-radius-md)
          [.sp-button-group-stacked_&:last-child]:rounded-b-(--sp-radius-md)
        ].freeze

        BASE = [*BASE_SHARED, "inline-flex", "items-center", "justify-center", "gap-(--sp-space-2)"].freeze

        GROUP_LAYOUTS = {
          inline:  %w[
            sp-button-group inline-flex rounded-(--sp-radius-md) shadow-(--sp-shadow-xs)
            [&>*:not(:first-child)]:-ml-px
          ].freeze,
          stacked: %w[
            sp-button-group-stacked flex flex-col rounded-(--sp-radius-md) shadow-(--sp-shadow-xs)
            [&>*:not(:first-child)]:-mt-px
          ].freeze
        }.freeze

        private

        def button_classes(type: :primary, variant: :default, size: :md)
          if type == :card
            {
              classes: klasses(
                *BASE_SHARED,
                *CARD_SIZE,
                *TYPES[:card],
                *CARD_VARIANTS.fetch(variant, CARD_VARIANTS[:default])
              )
            }
          else
            {
              classes: klasses(
                *BASE,
                *VARIANTS.fetch(variant, VARIANTS[:default]),
                *TYPES.fetch(type, TYPES[:primary]),
                *SIZES.fetch(size, [])
              )
            }
          end
        end

        def button_group_classes(layout: :inline)
          {
            classes: klasses(*GROUP_LAYOUTS.fetch(layout, GROUP_LAYOUTS[:inline]))
          }
        end

        def button_icon_classes
          { classes: klasses("size-(--sp-control-size)", "stroke-current") }
        end
      end
    end
  end
end
