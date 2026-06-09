# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module CalendarTurboHelper
      def sp_calendar_turbo_month(**kwargs)
        calendar_turbo_renderer.month(**kwargs)
      end

      def sp_calendar_turbo_year(**kwargs)
        calendar_turbo_renderer.year(**kwargs)
      end

      def sp_calendar_turbo_decade(**kwargs)
        calendar_turbo_renderer.decade(**kwargs)
      end

      def sp_calendar_turbo(
        date: Date.today,
        today: Date.today,
        selectable: false,
        selected_date: nil,
        show_other_months: false,
        **kwargs
      )
        safe_join(
          [
            content_tag(
              :turbo_frame,
              id:   "calendar-month-frame",
              data: { "combobox-date-target": "monthView" }
            ) do
              calendar_turbo_renderer.month(
                date:              date,
                today:             today,
                selectable:        selectable,
                selected_date:     selected_date,
                show_other_months: show_other_months,
                **kwargs
              )
            end,
            content_tag(
              :turbo_frame,
              id:     "calendar-year-frame",
              hidden: true,
              data:   { "combobox-date-target": "yearView" }
            ) do
              calendar_turbo_renderer.year(date: date, today: today, selected_date: selected_date)
            end,
            content_tag(
              :turbo_frame,
              id:     "calendar-decade-frame",
              hidden: true,
              data:   { "combobox-date-target": "decadeView" }
            ) do
              calendar_turbo_renderer.decade(date: date, today: today, selected_date: selected_date)
            end
          ]
        )
      end

      private

      def calendar_turbo_renderer
        @calendar_turbo_renderer ||= Components::Calendar::Turbo.new(self)
      end
    end
  end
end
