# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar < Plumber::Base
      MONTH_STIMULUS_CONTROLLER  = "calendar-month"
      YEAR_STIMULUS_CONTROLLER   = "calendar-year"
      DECADE_STIMULUS_CONTROLLER = "calendar-decade"
      OBSERVER_STIMULUS_CONTROLLER = "calendar-observer"
      STIMULUS_ACTION = "click->#{OBSERVER_STIMULUS_CONTROLLER}#onSelect".freeze

      def render(**kwargs)
        html_options = merge_html_options(
          theme.resolve(:calendar),
          kwargs,
          {
            data: {
              controller: "#{MONTH_STIMULUS_CONTROLLER} #{OBSERVER_STIMULUS_CONTROLLER}",
              action:     STIMULUS_ACTION
            }
          }
        )
        template.content_tag(:div, **html_options, role: "grid") do
          template.safe_join([month, year, decade])
        end
      end

      def month
        template.content_tag(:div, **month_options) do
          template.safe_join(
            [
              template.tag.div(**dow_options),
              template.tag.div(**dom_options)
            ]
          )
        end
      end

      def year
        template.tag.div(**year_options)
      end

      def decade
        template.tag.div(**decade_options)
      end

      private

      def month_options
        merge_html_options(
          {
            data: {
              "#{MONTH_STIMULUS_CONTROLLER}-row-class":          theme.resolve(:calendar_row).fetch(:classes, ""),
              "#{MONTH_STIMULUS_CONTROLLER}-day-of-month-class": theme.resolve(:calendar_day).fetch(:classes, "")
            }
          }
        )
      end

      def dow_options
        merge_html_options(
          theme.resolve(:calendar_days_of_week),
          { data: { "#{MONTH_STIMULUS_CONTROLLER}-target": "daysOfWeek" } }
        )
      end

      def dom_options
        merge_html_options(
          theme.resolve(:calendar_days_of_month),
          {
            role: "rowgroup",
            data: { "#{MONTH_STIMULUS_CONTROLLER}-target": "daysOfMonth" }
          }
        )
      end

      def year_options
        merge_html_options(
          { hidden: true, data: { controller: YEAR_STIMULUS_CONTROLLER } },
          {
            data: {
              "#{YEAR_STIMULUS_CONTROLLER}-month-class": theme.resolve(:calendar_month).fetch(:classes, "")
            }
          }
        )
      end

      def decade_options
        merge_html_options(
          { hidden: true, data: { controller: DECADE_STIMULUS_CONTROLLER } },
          {
            data: {
              "#{DECADE_STIMULUS_CONTROLLER}-year-class": theme.resolve(:calendar_year).fetch(:classes, "")
            }
          }
        )
      end
    end
  end
end
