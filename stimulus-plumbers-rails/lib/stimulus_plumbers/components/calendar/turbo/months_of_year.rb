# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class Turbo
        class MonthsOfYear < Plumber::Base
          MONTHS_PER_ROW = 4
          MONTH_FORMATS  = %i[narrow short long].freeze

          attr_reader :date, :today, :selected_date, :format

          def initialize(template, date: Date.today, today: Date.today, selected_date: nil, format: :short)
            super(template)
            @date          = date
            @today         = today
            @selected_date = selected_date
            @format        = format
          end

          def render(...)
            render_months_of_year(...)
          end

          private

          def render_months_of_year(**html_options)
            html_options = merge_html_options(
              theme.resolve(:calendar_months_of_year),
              html_options
            )
            template.content_tag(:div, role: "rowgroup", **html_options) { months_of_year }
          end

          def months_of_year
            row_options = merge_html_options(
              theme.resolve(:calendar_row),
              { role: "row" }
            )
            template.safe_join(
              month_names.each_slice(MONTHS_PER_ROW).map do |months|
                template.content_tag(:div, **row_options) { months_in_row(months) }
              end
            )
          end

          def month_names
            I18n.t("date.abbr_month_names").compact
                .zip(I18n.t("date.month_names").compact)
                .each_with_index.map { |(abbr, full), i| [i + 1, abbr, full] }
          end

          def months_in_row(months)
            template.safe_join(months.map { |number, abbr, full| month_cell(number, abbr, full) })
          end

          def month_cell(month_number, abbr, full)
            options = month_cell_html_options(month_number)
            options[:aria][:label] = abbr if format == :narrow
            template.content_tag(:button, display_name(abbr, full), **options)
          end

          def display_name(abbr, full)
            case format
            when :narrow then abbr[0, 1]
            when :long   then full
            else              abbr
            end
          end

          def month_cell_html_options(month_number)
            is_current_month = month_number == today.month && date.year == today.year
            is_focused = selected_date_in_month?(month_number) || (is_current_month && !selected_date_in_current_year?)
            merge_html_options(
              theme.resolve(:calendar_month),
              {
                role:     "gridcell",
                tabindex: is_focused ? 0 : -1,
                data:     { month: month_number },
                aria:     {
                  current:  is_current_month ? "month" : nil,
                  selected: selected_date_in_month?(month_number) ? "true" : "false"
                }
              }
            )
          end

          def selected_date_in_current_year?
            selected_date && selected_date.year == date.year
          end

          def selected_date_in_month?(month)
            selected_date && month == selected_date.month && date.year == selected_date.year
          end
        end
      end
    end
  end
end
