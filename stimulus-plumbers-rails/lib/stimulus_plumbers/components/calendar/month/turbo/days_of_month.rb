# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      module Month
        class Turbo
          class DaysOfMonth < Plumber::Base
            DAYS_IN_WEEK = 7

            attr_reader :date, :today, :selectable, :selected_date, :show_other_months

            def initialize(
              template,
              date: Date.today,
              today: Date.today,
              selectable: false,
              selected_date: nil,
              show_other_months: false
            )
              super(template)
              @date              = date
              @today             = today
              @selectable        = selectable
              @selected_date     = selected_date
              @show_other_months = show_other_months
            end

            def render(...)
              render_days_of_month(...)
            end

            private

            def render_days_of_month(**html_options)
              html_options = merge_html_options(
                { classes: theme.resolve(:calendar_days_of_month).fetch(:classes, "") },
                html_options
              )
              template.content_tag(:div, **html_options, role: "rowgroup") { weeks_of_month }
            end

            def weeks_of_month
              week_options = merge_html_options(
                { classes: theme.resolve(:calendar_week).fetch(:classes, "") },
                { role: "row" }
              )
              template.safe_join(
                build_days.each_slice(DAYS_IN_WEEK).map do |days|
                  template.content_tag(:div, **week_options) { days_in_week(days) }
                end
              )
            end

            def focus_day
              @focus_day ||= if selected_date_in_current_month?
                               selected_date
                             elsif today_in_current_month?
                               today
                             else
                               date.beginning_of_month
                             end
            end

            def build_days
              first        = date.beginning_of_month
              last         = date.end_of_month
              current_days = first.upto(last).to_a
              prev_filler_days(first) + current_days + next_filler_days(last, current_days.length)
            end

            def prev_filler_days(first_day_of_month)
              week_start = first_day_of_month - first_day_of_month.wday
              week_start.upto(first_day_of_month - 1).to_a
            end

            def next_filler_days(last_day_of_month, days_in_month)
              week_start_offset = last_day_of_month.beginning_of_month.wday
              total             = week_start_offset + days_in_month
              next_count = (DAYS_IN_WEEK - (total % DAYS_IN_WEEK)) % DAYS_IN_WEEK
              next_count.positive? ? (last_day_of_month + 1).upto(last_day_of_month + next_count).to_a : []
            end

            def selected_date_in_current_month?
              selected_date&.month == date.month && selected_date&.year == date.year
            end

            def today_in_current_month?
              today.month == date.month && today.year == date.year
            end

            def days_in_week(days)
              template.safe_join(
                days.map do |day|
                  if day.month == date.month
                    current_month_day_cell(day)
                  elsif show_other_months
                    other_month_day_cell(day)
                  else
                    hidden_day_cell(day)
                  end
                end
              )
            end

            def hidden_day_cell(date)
              template.content_tag(:span, role: "gridcell", tabindex: -1, aria: { hidden: "true" }) do
                template.content_tag(:time, nil, datetime: date.iso8601)
              end
            end

            def current_month_day_cell(date)
              tag = selectable ? :button : :span
              template.content_tag(tag, **day_cell_html_options(date, today)) do
                template.content_tag(:time, date.day.to_s, datetime: date.iso8601)
              end
            end

            def day_cell_html_options(date, today)
              is_today = date == today
              selected = selected_date && date == selected_date
              merge_html_options(
                { classes: theme.resolve(:calendar_day).fetch(:classes, "") },
                {
                  role:     "gridcell",
                  tabindex: date == focus_day ? 0 : -1,
                  aria:     {
                    current:  is_today ? "date" : nil,
                    selected: if selectable then selected ? "true" : "false" end
                  }
                }
              )
            end

            def other_month_day_cell(date)
              options = merge_html_options(
                { classes: theme.resolve(:calendar_day, outside: true).fetch(:classes, "") },
                { role: "gridcell", tabindex: -1, aria: { disabled: "true", selected: "false" } }
              )
              template.content_tag(:span, **options) do
                template.content_tag(:time, date.day.to_s, datetime: date.iso8601)
              end
            end
          end
        end
      end
    end
  end
end
