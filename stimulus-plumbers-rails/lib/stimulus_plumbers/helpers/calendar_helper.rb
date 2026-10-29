# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module CalendarHelper
      def sp_calendar(**kwargs)
        Components::Calendar.new(self).render(**kwargs)
      end
    end
  end
end
