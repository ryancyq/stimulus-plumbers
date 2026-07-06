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
                             "calendar-month-month-value": date.month - 1
                           }
                         )
                       else
                         kwargs
                       end
        Components::Calendar.new(self).month(**html_options)
      end
    end
  end
end
