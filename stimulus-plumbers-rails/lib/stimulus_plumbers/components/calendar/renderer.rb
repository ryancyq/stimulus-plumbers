# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Calendar
      class Renderer < Plumber::Base
        STIMULUS_CONTROLLER = "calendar-month"

        def month(stimulus_controller: nil, **kwargs)
          self.html_options = {
            classes: theme.resolve(:calendar).fetch(:classes, ""),
            data: {
              controller: STIMULUS_CONTROLLER,
            },
            **kwargs
          }

          template.content_tag(:div, role: "grid", **html_options) do
            template.safe_join([
              days_of_week(
                stimulus_controller: STIMULUS_CONTROLLER, 
                data: { "#{STIMULUS_CONTROLLER}-target" => "daysOfWeek"}
              ),
              days_of_month(
                stimulus_controller: STIMULUS_CONTROLLER, 
                data: { "#{STIMULUS_CONTROLLER}-target" => "daysOfMonth"}
              )
            ])
          end
        end

        def days_of_week(**kwargs)
          DaysOfWeek.new(template).days_of_week(**kwargs)
        end

        def days_of_month(**kwargs)
          DaysOfMonth.new(template).days_of_month(**kwargs)
        end
      end
    end
  end
end
