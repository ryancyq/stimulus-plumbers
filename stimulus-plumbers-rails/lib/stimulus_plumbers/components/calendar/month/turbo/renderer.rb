# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Calendar
      module Month
        module Turbo
          class Renderer < Plumber::Base
            STIMULUS_CONTROLLER = "calendar-month-observer"

            def render(
              date: Date.today,
              today: Date.today,
              selectable: false,
              selected_date: nil,
              show_other_months: false,
              **kwargs
            )
              html_options = merge_html_options(
                {
                  classes: theme.resolve(:calendar).fetch(:classes, ""),
                  data:    { controller: STIMULUS_CONTROLLER, action: "click->#{STIMULUS_CONTROLLER}#select" }
                },
                **kwargs
              )

              template.content_tag(:div, role: "grid", **html_options) do
                template.safe_join(
                  [
                    days_of_week,
                    days_of_month(
                      date:              date,
                      today:             today,
                      selectable:        selectable,
                      selected_date:     selected_date,
                      show_other_months: show_other_months
                    )
                  ]
                )
              end
            end

            private

            def days_of_week(**kwargs)
              DaysOfWeek.new(template).render(**kwargs)
            end

            def days_of_month(**kwargs)
              DaysOfMonth.new(template, **kwargs).render
            end
          end
        end
      end
    end
  end
end
