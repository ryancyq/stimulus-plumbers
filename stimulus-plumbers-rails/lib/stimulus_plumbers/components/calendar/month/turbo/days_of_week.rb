# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      module Month
        class Turbo
          class DaysOfWeek < Plumber::Base
            def render(...)
              render_days_of_week(...)
            end

            private

            def render_days_of_week(**html_options)
              html_options = merge_html_options(
                { classes: theme.resolve(:calendar_days_of_week).fetch(:classes, "") },
                html_options
              )
              template.content_tag(:div, **html_options) { days_of_week }
            end

            def days_of_week
              week_options = merge_html_options(
                { classes: theme.resolve(:calendar_week).fetch(:classes, "") },
                { role: "row" }
              )
              template.content_tag(:div, **week_options) do
                template.safe_join(
                  day_names.map { |abbr, full| template.content_tag(:span, abbr, role: "columnheader", abbr: full) }
                )
              end
            end

            def day_names
              I18n.t("date.abbr_day_names").zip(I18n.t("date.day_names"))
            end
          end
        end
      end
    end
  end
end
