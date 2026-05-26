# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module CalendarTurboHelper
      def sp_calendar_month_turbo(**kwargs)
        calendar_month_turbo_renderer.render(**kwargs)
      end

      private

      def calendar_month_turbo_renderer
        Components::Calendar::Month::Turbo.new(self)
      end
    end
  end
end
