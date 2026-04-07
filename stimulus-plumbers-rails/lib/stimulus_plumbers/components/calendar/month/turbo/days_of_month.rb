# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Calendar
      module Month
        module Turbo
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

            def render(**kwargs)
              html_options = merge_html_options(
                classes: theme.resolve(:calendar_days_of_month).fetch(:classes, ""),
                **kwargs
              )

              template.content_tag(:div, **html_options, role: "rowgroup") do
                template.safe_join(
                  build_days.each_slice(DAYS_IN_WEEK).map do |week|
                    template.content_tag(:div, role: "row") do
                      days_in_week(week)
                    end
                  end
                )
              end
            end

            private

            # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
            def focus_day
              @focus_day ||= if selected_date&.month == date.month && selected_date&.year == date.year
                               selected_date
                             elsif today.month == date.month && today.year == date.year
                               today
                             else
                               date.beginning_of_month
                             end
            end
            # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

            def build_days
              first = date.beginning_of_month
              last  = date.end_of_month

              prev_days    = (first - first.wday).upto(first - 1).to_a
              current_days = first.upto(last).to_a
              total        = prev_days.length + current_days.length
              next_count   = (DAYS_IN_WEEK - (total % DAYS_IN_WEEK)) % DAYS_IN_WEEK
              next_days    = next_count.positive? ? (last + 1).upto(last + next_count).to_a : []

              prev_days + current_days + next_days
            end

            def days_in_week(week)
              template.safe_join(
                week.map do |day|
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
              tag      = selectable ? :button : :span
              selected = selected_date && date == selected_date ? "true" : "false"
              template.content_tag(
                tag,
                role:     "gridcell",
                tabindex: date == focus_day ? 0 : -1,
                aria:     {
                  current:  date == today ? "date" : nil,
                  selected: selectable ? selected : nil
                }
              ) do
                template.content_tag(:time, date.day.to_s, datetime: date.iso8601)
              end
            end

            def other_month_day_cell(date)
              template.content_tag(
                :span,
                role:     "gridcell",
                tabindex: -1,
                aria:     { disabled: "true", selected: "false" }
              ) do
                template.content_tag(:time, date.day.to_s, datetime: date.iso8601)
              end
            end
          end
        end
      end
    end
  end
end
