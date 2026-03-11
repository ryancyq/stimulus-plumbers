# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Calendar
        BASE = %w[
          size-[--sp-calendar-day-size] rounded-[--sp-radius-md]
          flex items-center justify-center text-[--sp-text-sm]
          hover:bg-[--sp-color-muted] cursor-pointer
        ].freeze

        DAY_SELECTED = %w[
          bg-[--sp-color-primary]
          text-[--sp-color-primary-fg]
          hover:bg-[--sp-color-primary]/90
        ].freeze

        private

        def calendar_day_classes(today: false, selected: false, outside: false)
          {
            classes: klasses(
              *BASE,
              *(today    ? ["font-bold"] : []),
              *(selected ? DAY_SELECTED : []),
              *(outside  ? %w[text-[--sp-color-muted-fg] opacity-50] : [])
            )
          }
        end
      end
    end
  end
end
