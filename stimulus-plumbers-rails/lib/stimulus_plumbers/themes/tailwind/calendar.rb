# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Calendar
        GRID = %w[w-full].freeze

        DAYS_OF_WEEK = %w[
          grid grid-cols-7 text-center text-[--sp-text-xs]
          font-medium text-[--sp-color-muted-fg] mb-1
        ].freeze

        DAYS_OF_MONTH = %w[grid grid-cols-7].freeze

        DAY = %w[
          size-[--sp-calendar-day-size] rounded-[--sp-radius-md]
          flex items-center justify-center text-[--sp-text-sm]
          hover:bg-[--sp-color-muted] cursor-pointer
        ].freeze

        DAY_SELECTED = %w[
          bg-[--sp-color-primary]
          text-[--sp-color-primary-fg]
          hover:bg-[--sp-color-primary]/90
        ].freeze

        NAV = %w[flex items-center justify-between gap-1 mb-2].freeze

        NAV_BTN = %w[
          inline-flex items-center justify-center
          size-[--sp-calendar-day-size] rounded-[--sp-radius-md]
          text-[--sp-color-fg] hover:bg-[--sp-color-muted]
          focus-visible:outline-none focus-visible:ring-2
          focus-visible:ring-[--sp-focus-ring-color]
          disabled:pointer-events-none disabled:opacity-50
        ].freeze

        NAV_ICON = %w[size-4 stroke-current].freeze

        private

        def calendar_classes
          { classes: klasses(*GRID) }
        end

        def calendar_days_of_week_classes
          { classes: klasses(*DAYS_OF_WEEK) }
        end

        def calendar_days_of_month_classes
          { classes: klasses(*DAYS_OF_MONTH) }
        end

        def calendar_day_classes(today: false, selected: false, outside: false)
          {
            classes: klasses(
              *DAY,
              *(today    ? ["font-bold"] : []),
              *(selected ? DAY_SELECTED : []),
              *(outside  ? %w[text-[--sp-color-muted-fg] opacity-50] : [])
            )
          }
        end

        def calendar_navigation_classes
          { classes: klasses(*NAV) }
        end

        def calendar_navigation_navigator_classes
          { classes: klasses(*NAV_BTN) }
        end

        def calendar_navigation_navigator_icon_classes
          { classes: klasses(*NAV_ICON) }
        end
      end
    end
  end
end
