# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class Turbo
        class YearsOfDecade < Plumber::Base
          YEARS_PER_ROW = 4
          DECADE_SIZE   = 10

          attr_reader :date, :today, :selected_date

          def initialize(template, date: Date.today, today: Date.today, selected_date: nil)
            super(template)
            @date          = date
            @today         = today
            @selected_date = selected_date
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
              [y, y < decade_start || y > decade_start + DECADE_SIZE - 1]
            end
          end

          def years_in_row(years)
            template.safe_join(years.map { |year, outside| year_cell(year, outside) })
          end

          def year_cell(year, outside)
            template.content_tag(:button, year.to_s, **year_cell_html_options(year, outside))
          end

          def year_cell_html_options(year, outside)
            is_current_year = year == today.year
            is_focused      = selected_date_in_year?(year) || (is_current_year && !selected_date)
            merge_html_options(
              theme.resolve(:calendar_year, outside: outside),
              {
                role:     "gridcell",
                tabindex: is_focused ? 0 : -1,
                data:     { year: year },
                aria:     {
                  current:  is_current_year ? "year" : nil,
                  selected: selected_date_in_year?(year) ? "true" : "false",
                  disabled: outside ? "true" : nil
                }
              }
            )
          end

          def selected_date_in_year?(year)
            selected_date && year == selected_date.year
          end
        end
      end
    end
  end
end
