# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module CalendarTurboHelper
      def sp_calendar_month_turbo(
        date: Date.today,
        today: Date.today,
        selectable: false,
        selected_date: nil,
        show_other_months: false,
        **html_options
      )
        calendar_month_turbo_renderer.render(
          date:              date,
          today:             today,
          selectable:        selectable,
          selected_date:     selected_date,
          show_other_months: show_other_months,
          **html_options
        )
      end

      private

      def calendar_month_turbo_renderer
        Components::Calendar::Month::Turbo.new(self)
      end
    end
  end
end
