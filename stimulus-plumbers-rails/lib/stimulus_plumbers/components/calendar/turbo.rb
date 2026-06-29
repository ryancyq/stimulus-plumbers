# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class Turbo < Plumber::Base
        MONTH_SELECTOR_CONTROLLER   = "calendar-month-selector"
        YEAR_SELECTOR_CONTROLLER    = "calendar-year-selector"
        DECADE_SELECTOR_CONTROLLER  = "calendar-decade-selector"

        def month(
          date: Date.today,
          today: Date.today,
          show_other_months: false,
          weekday_format: :short,
          selectable: false,
          selected_date: nil,
          since: nil,
          till: nil,
          **kwargs
        )
          html_options = merge_html_options(
            theme.resolve(:calendar),
            kwargs,
            { data: { controller: MONTH_SELECTOR_CONTROLLER } }
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
                  show_other_months: show_other_months,
                  since:             since,
                  till:              till
                ).render
              ]
            )
          end
        end

        def year(
          date: Date.today,
          today: Date.today,
          selected_date: nil,
          month_format: :short,
          since: nil,
          till: nil,
          disabled_months: [],
          **kwargs
        )
          html_options = merge_html_options(
            theme.resolve(:calendar_quarter_grid),
            kwargs,
            {
              role: "grid",
              aria: { label: I18n.t("stimulus-plumbers.calendar.year_view") },
              data: { controller: YEAR_SELECTOR_CONTROLLER }
            }
          )
          template.content_tag(:div, **html_options) do
            Turbo::MonthsOfYear.new(
              template,
              date:            date,
              today:           today,
              selected_date:   selected_date,
              format:          month_format,
              since:           since,
              till:            till,
              disabled_months: disabled_months
            ).render
          end
        end

        def decade(
          date: Date.today,
          today: Date.today,
          selected_date: nil,
          since: nil,
          till: nil,
          disabled_years: [],
          **kwargs
        )
          html_options = merge_html_options(
            theme.resolve(:calendar_quarter_grid),
            kwargs,
            {
              role: "grid",
              aria: { label: I18n.t("stimulus-plumbers.calendar.decade_view") },
              data: { controller: DECADE_SELECTOR_CONTROLLER }
            }
          )
          template.content_tag(:div, **html_options) do
            Turbo::YearsOfDecade.new(
              template,
              date:           date,
              today:          today,
              selected_date:  selected_date,
              since:          since,
              till:           till,
              disabled_years: disabled_years
            ).render
          end
        end
      end
    end
  end
end
