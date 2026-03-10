# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Calendar
      class Renderer < Plumber::Base
        attr_reader :stimulus_controller, :navigation_unit

        def month(**kwargs)
          self.html_options = {
            classes: theme.resolve(:calendar).fetch(:classes, ""),
            data: {
              controller: "calendar-month",
            },
            **kwargs
          }

          @stimulus_controller = html_options.dig(:data, :controller)
          @navigation_unit = "month"

          template.content_tag(:div, **html_options) do
            template.safe_join([
              navigation,
              days_of_week,
              days_of_month
            ])
          end
        end

        def navigation(**kwargs)
          template.safe_join([
            Navigator.new(template).navigator(
              icon_options: { name: "arrow-left" },
              aria: { label: ["previous", navigation_unit].join(" ").titleize },
              data: { "#{stimulus_controller}-target" => "previous"}
            ),
            Navigator.new(template).navigator(
              data: { "#{stimulus_controller}-target" => "day"}
            ),
            Navigator.new(template).navigator(
              data: { "#{stimulus_controller}-target" => "month"}
            ),
            Navigator.new(template).navigator(
              data: { "#{stimulus_controller}-target" => "year"}
            ),
            Navigator.new(template).navigator(
              icon_options: { name: "arrow-right" },
              aria: { label: ["next", navigation_unit].join(" ").titleize },
              data: { "#{stimulus_controller}-target" => "next"}
            )
          ])
        end

        def days_of_week(**kwargs)
          DaysOfWeek.new(template).days_of_week(data: { "calendar-month-target" => "daysOfWeek"})
        end

        def days_of_month(**html_options)
          DaysOfMonth.new(template).days_of_month(data: { "calendar-month-target" => "daysOfMonth"})
        end
      end
    end
  end
end
