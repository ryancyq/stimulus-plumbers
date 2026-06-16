# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar < Plumber::Base
      MONTH_STIMULUS_CONTROLLER  = "calendar-month"
      YEAR_STIMULUS_CONTROLLER   = "calendar-year"
      DECADE_STIMULUS_CONTROLLER = "calendar-decade"

      def month(**kwargs)
        html_options = merge_html_options(
          theme.resolve(:calendar),
          kwargs,
          { data: { controller: MONTH_STIMULUS_CONTROLLER } },
          { data: stimulus_theme_options }
        )
        template.content_tag(:div, **html_options, role: "grid") do
          template.safe_join([days_of_week, days_of_month])
        end
      end

      def year(**kwargs)
        html_options = merge_html_options(
          {
            hidden: true,
            role:   "grid",
            aria:   { label: I18n.t("stimulus_plumbers.calendar.year_view") },
            data:   { controller: YEAR_STIMULUS_CONTROLLER }
          },
          kwargs
        )
        template.content_tag(:div, **html_options) do
          template.tag.div(data: { "#{YEAR_STIMULUS_CONTROLLER}-target": "grid" }, role: "rowgroup")
        end
      end

      def decade(**kwargs)
        html_options = merge_html_options(
          {
            hidden: true,
            role:   "grid",
            aria:   { label: I18n.t("stimulus_plumbers.calendar.decade_view") },
            data:   { controller: DECADE_STIMULUS_CONTROLLER }
          },
          kwargs
        )
        template.content_tag(:div, **html_options) do
          template.tag.div(data: { "#{DECADE_STIMULUS_CONTROLLER}-target": "grid" }, role: "rowgroup")
        end
      end

      private

      def stimulus_theme_options
        {
          "#{MONTH_STIMULUS_CONTROLLER}-row-class":                theme.resolve(:calendar_row).fetch(:classes, ""),
          "#{MONTH_STIMULUS_CONTROLLER}-day-of-month-class":       theme.resolve(:calendar_day).fetch(:classes, ""),
          "#{MONTH_STIMULUS_CONTROLLER}-day-of-other-month-class": theme.resolve(:calendar_day, outside: true).fetch(:classes, "")
        }
      end

      def days_of_week
        template.tag.div(
          **merge_html_options(
            theme.resolve(:calendar_days_of_week),
            { data: { "#{MONTH_STIMULUS_CONTROLLER}-target": "daysOfWeek" } }
          )
        )
      end

      def days_of_month
        template.tag.div(
          **merge_html_options(
            theme.resolve(:calendar_days_of_month),
            {
              role: "rowgroup",
              data: { "#{MONTH_STIMULUS_CONTROLLER}-target": "daysOfMonth" }
            }
          )
        )
      end
    end
  end
end
