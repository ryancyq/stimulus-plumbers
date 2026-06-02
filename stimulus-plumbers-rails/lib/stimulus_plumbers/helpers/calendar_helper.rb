# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module CalendarHelper
      def sp_calendar_month(**kwargs)
        date = kwargs.delete(:date)
        html_options = if date
                         kwargs.deep_merge(
                           data: {
                             "calendar-month-year-value":  date.year,
                             "calendar-month-month-value": date.month - 1,
                             "calendar-month-day-value":   date.day
                           }
                         )
                       else
                         kwargs
                       end
        calendar_renderer.render(**html_options)
      end

      private

      def calendar_renderer
        Components::Calendar.new(self)
      end
    end
  end
end
