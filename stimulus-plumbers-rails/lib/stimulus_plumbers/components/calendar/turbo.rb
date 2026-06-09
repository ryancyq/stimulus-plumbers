# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class Turbo < Plumber::Base
        STIMULUS_CONTROLLER = "calendar-observer"
        STIMULUS_ACTION     = "click->#{STIMULUS_CONTROLLER}#onSelect".freeze

        def month(
          date: Date.today,
          today: Date.today,
          show_other_months: false,
          weekday_format: :short,
          **kwargs
        )
          selectable = kwargs.delete(:selectable) { false }
          selected_date = kwargs.delete(:selected_date) { nil }
          html_options = merge_html_options(
            theme.resolve(:calendar),
            kwargs,
            { data: { controller: STIMULUS_CONTROLLER, action: STIMULUS_ACTION } }
          )
          template.content_tag(:div, role: "grid", **html_options) do
            template.safe_join(
              [
                Turbo::DaysOfWeek.new(template, format: weekday_format).render,
                Turbo::DaysOfMonth.new(
                  template,
                  date:              date,
                  today:             today,
                  selectable:        selectable,
                  selected_date:     selected_date,
                  show_other_months: show_other_months
                ).render
              ]
            )
          end
        end

        def year(date: Date.today, today: Date.today, selected_date: nil, month_format: :short, **kwargs)
          html_options = merge_html_options(
            theme.resolve(:calendar_quarter_grid),
            kwargs,
            { role: "grid", aria: { label: "Year view" } }
          )
          template.content_tag(:div, **html_options) do
            Turbo::MonthsOfYear.new(template, date: date, today: today, selected_date: selected_date, format: month_format).render
          end
        end

        def decade(date: Date.today, today: Date.today, selected_date: nil, **kwargs)
          html_options = merge_html_options(
            theme.resolve(:calendar_quarter_grid),
            kwargs,
            { role: "grid", aria: { label: "Decade view" } }
          )
          template.content_tag(:div, **html_options) do
            Turbo::YearsOfDecade.new(template, date: date, today: today, selected_date: selected_date).render
          end
        end
      end
    end
  end
end
