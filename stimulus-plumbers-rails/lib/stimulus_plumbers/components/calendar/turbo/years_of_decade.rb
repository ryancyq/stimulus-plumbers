# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class Turbo
        class YearsOfDecade < Plumber::Base
          YEARS_PER_ROW = 4
          DECADE_SIZE   = 10

          attr_reader :date, :today, :selected_date, :since, :till, :disabled_years

          def initialize(
            template,
            date: Date.today,
            today: Date.today,
            selected_date: nil,
            since: nil,
            till: nil,
            disabled_years: []
          )
            super(template)
            @date           = date
            @today          = today
            @selected_date  = selected_date
            @since          = since
            @till           = till
            @disabled_years = disabled_years
          end

          def render(...)
            render_years_of_decade(...)
          end

          private

          def render_years_of_decade(**html_options)
            html_options = merge_html_options(
              theme.resolve(:calendar_years_of_decade),
              html_options
            )
            template.content_tag(:div, role: "rowgroup", **html_options) { years_of_decade }
          end

          def years_of_decade
            row_options = merge_html_options(
              theme.resolve(:calendar_row),
              { role: "row" }
            )
            template.safe_join(
              year_names.each_slice(YEARS_PER_ROW).map do |years|
                template.content_tag(:div, **row_options) { years_in_row(years) }
              end
            )
          end

          def year_names
            decade_start = (date.year / DECADE_SIZE) * DECADE_SIZE
            ((decade_start - 1)..(decade_start + DECADE_SIZE)).map do |y|
              [y, year_disabled?(y, decade_start)]
            end
          end

          def years_in_row(years)
            template.safe_join(years.map { |year, disabled| year_cell(year, disabled) })
          end

          def year_cell(year, disabled)
            template.content_tag(:button, year.to_s, **year_cell_html_options(year, disabled))
          end

          def year_cell_html_options(year, disabled)
            merge_html_options(
              theme.resolve(:calendar_year),
              {
                role:     "gridcell",
                tabindex: focused_year?(year, disabled) ? 0 : -1,
                data:     { year: year },
                aria:     {
                  current:  current_year?(year) ? "year" : nil,
                  selected: selected_date_in_year?(year) ? "true" : "false",
                  disabled: disabled ? "true" : nil
                }
              }
            )
          end

          def year_disabled?(year, decade_start)
            outside_decade?(year, decade_start) ||
              (since && year < since.year) ||
              (till && year > till.year) ||
              disabled_years.any? { |v| v.to_s == year.to_s }
          end

          def outside_decade?(year, decade_start)
            year < decade_start || year > (decade_start + DECADE_SIZE - 1)
          end

          def current_year?(year)
            year == today.year
          end

          def focused_year?(year, disabled)
            !disabled && (selected_date_in_year?(year) || (current_year?(year) && !selected_date))
          end

          def selected_date_in_year?(year)
            selected_date && year == selected_date.year
          end
        end
      end
    end
  end
end
