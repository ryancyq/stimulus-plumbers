# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Calendar
      class Renderer < Plumber::Base
        STIMULUS_CONTROLLER          = "calendar-month"
        OBSERVER_STIMULUS_CONTROLLER = "calendar-month-observer"
        STIMULUS_DATA                = {
          controller: "#{STIMULUS_CONTROLLER} #{OBSERVER_STIMULUS_CONTROLLER}",
          action:     "click->#{OBSERVER_STIMULUS_CONTROLLER}#select"
        }.freeze

        def month(**kwargs)
          html_options = merge_html_options(
            { classes: theme.resolve(:calendar).fetch(:classes, ""), data: STIMULUS_DATA },
            kwargs
          )

          template.content_tag(:div, role: "grid", **html_options) do
            template.safe_join(
              [
                template.tag.div(data: { "#{STIMULUS_CONTROLLER}-target" => "daysOfWeek" }),
                template.tag.div(
                  role: "rowgroup",
                  data: { "#{STIMULUS_CONTROLLER}-target" => "daysOfMonth" }
                )
              ]
            )
          end
        end
      end
    end
  end
end
