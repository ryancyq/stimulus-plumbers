# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Calendar
        GRID = [].freeze

        STATUS     = %w[sr-only].freeze
        HEADER     = %w[flex items-center gap-(--sp-space-1) mb-(--sp-space-2)].freeze
        HEADING    = %w[flex-1 text-center text-(length:--sp-text-sm) font-semibold text-(--sp-color-fg)].freeze
        NAVIGATION = %w[
          inline-flex items-center justify-center min-h-(--sp-calendar-day-size) min-w-(--sp-calendar-day-size)
          px-(--sp-space-2) rounded-(--sp-radius-md) text-(length:--sp-text-sm) text-(--sp-color-fg)
          hover:bg-(--sp-color-muted)
          aria-disabled:opacity-40 aria-disabled:cursor-not-allowed aria-disabled:hover:bg-transparent
          focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-(--sp-focus-ring-color)
        ].freeze
        GRID_TABLE = %w[w-full border-collapse [[aria-busy=true]_&]:opacity-60].freeze
        WEEKDAY    = %w[pb-(--sp-space-1) text-center text-(length:--sp-text-xs) font-medium text-(--sp-color-muted-fg)].freeze
        CELL       = %w[p-(--sp-space-0-5) text-center].freeze
        DATE = %w[
          inline-flex items-center justify-center w-full min-h-(--sp-calendar-day-size) min-w-(--sp-calendar-day-size)
          rounded-(--sp-radius-md) text-(length:--sp-text-sm) leading-tight text-(--sp-color-fg)
          cursor-pointer hover:bg-(--sp-color-muted)
          focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-(--sp-focus-ring-color)
          aria-[current=date]:font-bold aria-[current=date]:underline aria-[current=date]:underline-offset-4
          [[aria-selected=true]>&]:bg-(--sp-color-primary) [[aria-selected=true]>&]:text-(--sp-color-primary-fg)
          [[aria-selected=true]>&]:hover:bg-(--sp-color-primary)/90
          forced-colors:[[aria-selected=true]>&]:forced-color-adjust-none
          forced-colors:[[aria-selected=true]>&]:bg-[Highlight] forced-colors:[[aria-selected=true]>&]:text-[HighlightText]
          data-outside:text-(--sp-color-muted-fg)
          aria-disabled:opacity-40 aria-disabled:line-through aria-disabled:cursor-not-allowed
          aria-disabled:hover:bg-transparent
        ].freeze

        private

        def calendar_classes
          { classes: class_names(*GRID) }
        end

        def calendar_status_classes
          { classes: class_names(*STATUS) }
        end

        def calendar_header_classes
          { classes: class_names(*HEADER) }
        end

        def calendar_heading_classes
          { classes: class_names(*HEADING) }
        end

        def calendar_navigation_classes
          { classes: class_names(*NAVIGATION) }
        end

        def calendar_grid_classes
          { classes: class_names(*GRID_TABLE) }
        end

        def calendar_weekday_classes
          { classes: class_names(*WEEKDAY) }
        end

        def calendar_cell_classes
          { classes: class_names(*CELL) }
        end

        def calendar_date_classes
          { classes: class_names(*DATE) }
        end
      end
    end
  end
end
