# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Button
        VARIANTS = {
          primary:     %w[
            bg-[--sp-color-primary]
            text-[--sp-color-primary-fg]
            hover:bg-[--sp-color-primary]/90
            focus-visible:ring-[--sp-focus-ring-color]
          ].freeze,
          secondary:   %w[
            bg-[--sp-color-muted]
            text-[--sp-color-fg]
            hover:bg-[--sp-color-border]
          ].freeze,
          outline:     %w[
            border border-[--sp-color-border]
            bg-transparent
            text-[--sp-color-fg]
            hover:bg-[--sp-color-muted]
          ].freeze,
          destructive: %w[
            bg-[--sp-color-destructive]
            text-[--sp-color-destructive-fg]
            hover:bg-[--sp-color-destructive]/90
          ].freeze,
          ghost:       %w[hover:bg-[--sp-color-muted] text-[--sp-color-fg]].freeze,
          link:        %w[text-[--sp-color-primary] underline-offset-4 hover:underline].freeze
        }.freeze

        SIZES = {
          sm: %w[h-8 px-[--sp-space-3] text-[--sp-text-sm]].freeze,
          md: %w[h-9 px-[--sp-space-4] text-[--sp-text-base]].freeze,
          lg: %w[h-11 px-[--sp-space-6] text-[--sp-text-lg]].freeze
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

        BASE = %w[
          inline-flex items-center justify-center gap-2 font-medium
          rounded-[--sp-radius-md] transition-colors
          focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2
          disabled:pointer-events-none disabled:opacity-50
        ].freeze

        GROUP_BASE = %w[flex gap-[--sp-space-2]].freeze

        private

        def button_classes(variant: :primary, size: :md)
          {
            classes: klasses(
              *BASE,
              *VARIANTS.fetch(variant, []),
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
      end
    end
  end
end
