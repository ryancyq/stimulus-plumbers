# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module CalendarHelper
      def sp_calendar_month(**kwargs, &block)
        date = kwargs.delete(:date)
        if date
          html_options = kwargs.deep_merge(
            data: {
              "calendar-month-year-value":  date.year,
              "calendar-month-month-value": date.month - 1,
              "calendar-month-day-value":   date.day
            }
          )
        end
        calendar_renderer.month(**html_options, &block)
      end

      private

      def calendar_renderer
        Components::Calendar.new(self)
      end
    end
  end
end
