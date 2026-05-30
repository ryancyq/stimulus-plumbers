# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar < Plumber::Base
      STIMULUS_CONTROLLER          = "calendar-month"
      OBSERVER_STIMULUS_CONTROLLER = "calendar-month-observer"
      STIMULUS_ACTION              = [
        "click->#{OBSERVER_STIMULUS_CONTROLLER}#onSelect",
        "#{OBSERVER_STIMULUS_CONTROLLER}:selected->#{STIMULUS_CONTROLLER}#onSelect"
      ].join(" ").freeze
      STIMULUS_DATA = {
        controller: "#{STIMULUS_CONTROLLER} #{OBSERVER_STIMULUS_CONTROLLER}",
        action:     STIMULUS_ACTION
      }.freeze

      def month(**kwargs)
        template.content_tag(:div, role: "grid", **month_html_options(kwargs)) do
          template.safe_join([template.tag.div(**dow_options), template.tag.div(**dom_options)])
        end
      end

      private

      def month_html_options(kwargs)
        merge_html_options(
          {
            classes: theme.resolve(:calendar).fetch(:classes, ""),
            data:    month_stimulus_data
          },
          kwargs
        )
      end

      def month_stimulus_data
        STIMULUS_DATA.merge(
          calendar_month_week_class:         theme.resolve(:calendar_week).fetch(:classes, ""),
          calendar_month_day_of_month_class: theme.resolve(:calendar_day).fetch(:classes, "")
        ).compact_blank
      end

      def dow_options
        merge_html_options(
          { classes: theme.resolve(:calendar_days_of_week).fetch(:classes, "") },
          { data: { "#{STIMULUS_CONTROLLER}-target": "daysOfWeek" } }
        )
      end

      def dom_options
        merge_html_options(
          { classes: theme.resolve(:calendar_days_of_month).fetch(:classes, "") },
          {
            role: "rowgroup",
            data: { "#{STIMULUS_CONTROLLER}-target": "daysOfMonth" }
          }
        )
      end
    end
  end
end
