# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Calendar
        GRID = %w[w-full].freeze

        DAYS_OF_WEEK = %w[
          grid grid-cols-7 text-center text-(length:--sp-text-xs)
          font-medium text-(--sp-color-muted-fg) mb-(--sp-space-1)
        ].freeze

        DAYS_OF_MONTH = %w[grid grid-cols-7 justify-items-center].freeze

        DAY = %w[
          size-(--sp-calendar-day-size) rounded-(--sp-radius-md)
          flex items-center justify-center text-(length:--sp-text-sm)
          hover:bg-(--sp-color-muted) cursor-pointer
          aria-[current=date]:font-bold
          aria-selected:bg-(--sp-color-primary)
          aria-selected:text-(--sp-color-primary-fg)
          aria-selected:hover:bg-(--sp-color-primary)/90
          aria-[hidden=true]:pointer-events-none
          aria-[hidden=true]:hover:bg-transparent
        ].freeze

        QUARTER_GRID = %w[grid grid-cols-4 gap-(--sp-space-1)].freeze

        MONTHS_OF_YEAR = "contents"

        MONTH = %w[
          rounded-(--sp-radius-md) flex items-center justify-center
          text-(length:--sp-text-sm) h-10 flex-1
          hover:bg-(--sp-color-muted) cursor-pointer
          aria-selected:bg-(--sp-color-primary)
          aria-selected:text-(--sp-color-primary-fg)
          aria-selected:hover:bg-(--sp-color-primary)/90
          aria-disabled:pointer-events-none aria-disabled:text-(--sp-color-disabled-fg)
          aria-[current=month]:font-bold
        ].freeze

        YEARS_OF_DECADE = "contents"

        YEAR = %w[
          rounded-(--sp-radius-md) flex items-center justify-center
          text-(length:--sp-text-sm) h-10 flex-1
          hover:bg-(--sp-color-muted) cursor-pointer
          aria-selected:bg-(--sp-color-primary)
          aria-selected:text-(--sp-color-primary-fg)
          aria-selected:hover:bg-(--sp-color-primary)/90
          aria-disabled:pointer-events-none aria-disabled:text-(--sp-color-disabled-fg)
          aria-[current=year]:font-bold
        ].freeze

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

        def calendar_months_of_year_classes
          { classes: MONTHS_OF_YEAR }
        end

        def calendar_years_of_decade_classes
          { classes: YEARS_OF_DECADE }
        end

        def calendar_row_classes
          { classes: "contents" }
        end

        def calendar_day_classes(outside: false, **)
          {
            classes: klasses(
              *DAY,
              *(outside ? %w[text-(--sp-color-disabled-fg)] : [])
            )
          }
        end

        def calendar_month_classes(**)
          { classes: klasses(*MONTH) }
        end

        def calendar_year_classes(**)
          { classes: klasses(*YEAR) }
        end

        def calendar_quarter_grid_classes
          { classes: klasses(*QUARTER_GRID) }
        end
      end
    end
  end
end
