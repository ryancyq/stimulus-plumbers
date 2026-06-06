# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Button
        VARIANTS = {
          primary:     %w[
            [--btn-bg:var(--sp-color-primary)]
            [--btn-fg:var(--sp-color-primary-fg)]
            [--btn-accent:var(--sp-color-primary)]
            [--btn-border:var(--sp-color-primary-border)]
            [--btn-ring:var(--sp-color-primary-ring)]
          ].freeze,
          secondary:   %w[
            [--btn-bg:var(--sp-color-secondary)]
            [--btn-fg:var(--sp-color-secondary-fg)]
            [--btn-accent:var(--sp-color-secondary)]
            [--btn-border:var(--sp-color-secondary-border)]
            [--btn-ring:var(--sp-color-secondary-ring)]
          ].freeze,
          tertiary:    %w[
            [--btn-bg:var(--sp-color-muted)]
            [--btn-fg:var(--sp-color-muted-fg)]
            [--btn-accent:var(--sp-color-fg)]
            [--btn-border:var(--sp-color-muted-border)]
            [--btn-ring:var(--sp-color-muted-ring)]
          ].freeze,
          success:     %w[
            [--btn-bg:var(--sp-color-success)]
            [--btn-fg:var(--sp-color-success-fg)]
            [--btn-accent:var(--sp-color-success)]
            [--btn-border:var(--sp-color-success-border)]
            [--btn-ring:var(--sp-color-success-ring)]
          ].freeze,
          destructive: %w[
            [--btn-bg:var(--sp-color-destructive)]
            [--btn-fg:var(--sp-color-destructive-fg)]
            [--btn-accent:var(--sp-color-destructive)]
            [--btn-border:var(--sp-color-destructive-border)]
            [--btn-ring:var(--sp-color-destructive-ring)]
          ].freeze,
          warning:     %w[
            [--btn-bg:var(--sp-color-warning)]
            [--btn-fg:var(--sp-color-warning-fg)]
            [--btn-accent:var(--sp-color-warning)]
            [--btn-border:var(--sp-color-warning-border)]
            [--btn-ring:var(--sp-color-warning-ring)]
          ].freeze,
          info:        %w[
            [--btn-bg:var(--sp-color-info)]
            [--btn-fg:var(--sp-color-info-fg)]
            [--btn-accent:var(--sp-color-info)]
            [--btn-border:var(--sp-color-info-border)]
            [--btn-ring:var(--sp-color-info-ring)]
          ].freeze
        }.freeze

        TYPES = {
          default:     %w[
            rounded-(--sp-radius-md)
            bg-(--btn-bg) text-(--btn-fg)
            border border-(--btn-border)
            hover:bg-(--btn-bg)/90
          ].freeze,
          outline:     %w[
            rounded-(--sp-radius-md)
            bg-(--sp-color-bg) text-(--btn-accent)
            border border-(--btn-border)
            hover:bg-(--btn-bg)/10
          ].freeze,
          ghost:       %w[
            rounded-(--sp-radius-md)
            bg-transparent text-(--btn-accent)
            border border-transparent
            hover:bg-(--btn-bg)/10
          ].freeze,
          fab:         %w[
            rounded-(--sp-radius-full)
            bg-(--btn-bg) text-(--btn-fg)
            border border-(--btn-border)
            shadow-(--sp-shadow-lg)
            hover:bg-(--btn-bg)/90 hover:shadow-(--sp-shadow-xl)
          ].freeze,
          fab_outline: %w[
            rounded-(--sp-radius-full)
            bg-transparent text-(--btn-accent)
            border border-(--btn-border)
            shadow-(--sp-shadow-lg)
            hover:bg-(--btn-bg) hover:text-(--btn-fg) hover:shadow-(--sp-shadow-xl)
          ].freeze,
          dashed:      %w[
            rounded-(--sp-radius-md)
            bg-(--sp-color-bg) text-(--btn-accent)
            border border-dashed border-(--btn-border)
            hover:bg-(--btn-bg)/10
          ].freeze,
          card:        %w[
            rounded-(--sp-radius-md)
            bg-(--sp-color-bg) text-(--btn-accent)
            border border-(--btn-border) shadow-(--sp-shadow-xs)
            hover:bg-(--btn-bg)/10
          ].freeze
        }.freeze

        SIZES = {
          xs: %w[h-7 px-(--sp-space-2) text-(length:--sp-text-xs)].freeze,
          sm: %w[h-8 px-(--sp-space-3) text-(length:--sp-text-sm)].freeze,
          md: %w[h-9 px-(--sp-space-4) text-(length:--sp-text-base)].freeze,
          lg: %w[h-11 px-(--sp-space-6) text-(length:--sp-text-lg)].freeze,
          xl: %w[h-14 px-(--sp-space-6) text-(length:--sp-text-lg)].freeze
        }.freeze

        BASE = [
          *Control::BASE,
          "whitespace-nowrap",
          "focus-visible:ring-(--btn-ring)"
        ].freeze

        LAYOUT = %w[
          inline-flex items-center justify-center gap-(--sp-space-2)
          [&:not(:has(>span))]:aspect-square
          [&:not(:has(>span))]:px-0
        ].freeze

        CARD = %w[
          inline-flex justify-start items-center flex-1 gap-(--sp-space-3) p-(--sp-space-4)
          [&>:last-child:not(:first-child)]:ml-auto
        ].freeze

        private

        def button_classes(type: :default, variant: :primary, size: :md)
          {
            classes: klasses(
              *BASE,
              *(type == :card ? CARD : LAYOUT),
              *VARIANTS.fetch(variant, VARIANTS[:primary]),
              *TYPES.fetch(type, TYPES[:default]),
              *(type == :card ? [] : SIZES.fetch(size, []))
            )
          }
        end

        def button_icon_classes
          { classes: klasses("size-(--sp-control-size)", "stroke-current") }
        end
      end
    end
  end
end
