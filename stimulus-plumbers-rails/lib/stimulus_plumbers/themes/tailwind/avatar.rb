# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Avatar
        COLORS = {
          amber:   "text-white bg-amber-600",
          lime:    "text-white bg-lime-600",
          sky:     "text-white bg-sky-600",
          cyan:    "text-white bg-cyan-600",
          teal:    "text-white bg-teal-600",
          emerald: "text-white bg-emerald-600",
          indigo:  "text-white bg-indigo-600",
          fuchsia: "text-white bg-fuchsia-600",
          rose:    "text-white bg-rose-600",
          pink:    "text-white bg-pink-600",
          violet:  "text-white bg-violet-600",
          blue:    "text-white bg-blue-600"
        }.freeze

        SIZES = {
          sm: "size-[--sp-icon-size]",
          md: "size-[--sp-avatar-size]",
          lg: "size-12"
        }.freeze

        BASE = %w[rounded-[--sp-radius-full] overflow-hidden inline-flex items-center justify-center].freeze

        def avatar_colors
          COLORS
        end

        def avatar_color_range
          COLORS.values
        end

        private

        def avatar_classes(size: :md, color: nil)
          {
            classes: klasses(
              SIZES.fetch(size, SIZES[:md]),
              COLORS.fetch(color, nil),
              *BASE
            )
          }
        end
      end
    end
  end
end
