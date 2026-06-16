# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class Turbo
        class MonthsOfYear < Plumber::Base
          YEAR_SIZE      = 12
          MONTHS_PER_ROW = 4
          MONTH_FORMATS  = %i[narrow short long].freeze

          attr_reader :date, :today, :selected_date, :format, :since, :till, :disabled_months

          def initialize(
            template,
            date: Date.today,
            today: Date.today,
            selected_date: nil,
            format: :short,
            since: nil,
            till: nil,
            disabled_months: []
          )
            super(template)
            @date           = date
            @today          = today
            @selected_date  = selected_date
            @format         = format
            @since          = since
            @till           = till
            @disabled_months = disabled_months
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
            I18n.t("date.abbr_month_names").compact.first(YEAR_SIZE)
                .zip(I18n.t("date.month_names").compact.first(YEAR_SIZE))
                .each_with_index.map do |(abbr, full), i|
                  month_num = i + 1
                  [month_num, abbr, full, month_disabled?(month_num, abbr, full)]
                end
          end

          def months_in_row(months)
            template.safe_join(months.map { |number, abbr, full, disabled| month_cell(number, abbr, full, disabled) })
          end

          def month_cell(month_number, abbr, full, disabled)
            options = month_cell_html_options(month_number, disabled)
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

          def month_cell_html_options(month_number, disabled)
            merge_html_options(
              theme.resolve(:calendar_month),
              {
                role:     "gridcell",
                tabindex: focused_month?(month_number, disabled) ? 0 : -1,
                data:     { month: month_number },
                aria:     {
                  current:  current_month?(month_number) ? "month" : nil,
                  selected: selected_date_in_month?(month_number) ? "true" : "false",
                  disabled: disabled ? "true" : nil
                }
              }
            )
          end

          def month_disabled?(month_num, abbr, full)
            month_start = Date.new(date.year, month_num, 1)
            month_end   = Date.new(date.year, month_num, -1)
            (since && month_end < since) ||
              (till && month_start > till) ||
              month_in_disabled_list?(month_num, abbr, full)
          end

          def month_in_disabled_list?(month_num, abbr, full)
            disabled_months.any? { |v| v.to_s == month_num.to_s } ||
              disabled_months.include?(abbr) ||
              disabled_months.include?(full)
          end

          def current_month?(month_number)
            month_number == today.month && date.year == today.year
          end

          def focused_month?(month_number, disabled)
            !disabled && (selected_date_in_month?(month_number) ||
              (current_month?(month_number) && !selected_date_in_current_year?))
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
