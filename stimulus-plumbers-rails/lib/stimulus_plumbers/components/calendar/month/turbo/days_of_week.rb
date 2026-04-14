# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Calendar
      module Month
        module Turbo
          class DaysOfWeek < Plumber::Base
            def render(**kwargs)
              html_options = merge_html_options(
                { classes: theme.resolve(:calendar_days_of_week).fetch(:classes, "") },
                kwargs
              )

              template.content_tag(:div, **html_options) do
                template.content_tag(:div, role: "row") do
                  template.safe_join(
                    day_names.map do |abbr, full|
                      template.content_tag(:span, abbr, role: "columnheader", abbr: full)
                    end
                  )
                end
              end
            end

            private

            def day_names
              I18n.t("date.abbr_day_names").zip(I18n.t("date.day_names"))
            end
          end
        end
      end
    end
  end
end
