# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Calendar
      class DaysOfMonth < Plumber::Base
        DAYS_IN_WEEK = 7

        def days_of_month(date: Date.today, stimulus_controller: nil, **kwargs)
          self.html_options = {
            classes: theme.resolve(:calendar_days_of_month).fetch(:classes, ""),
            **kwargs
          }

          template.content_tag(:div, **html_options) do
            template.safe_join(
              build_days(date).each_slice(DAYS_IN_WEEK).map do |week|
                template.content_tag(:div, role: "row") do
                  days_in_week(date, week)
                end
              end
            )
          end
        end

        private

        def build_days(date)
          first = Date.new(date.year, date.month, 1)
          last  = Date.new(date.year, date.month, -1)

          prev_days    = (first - first.wday).upto(first - 1).to_a
          current_days = first.upto(last).to_a
          total        = prev_days.length + current_days.length
          next_count   = (DAYS_IN_WEEK - total % DAYS_IN_WEEK) % DAYS_IN_WEEK
          next_days    = next_count > 0 ? (last + 1).upto(last + next_count).to_a : []

          prev_days + current_days + next_days
        end

        def days_in_week(date, week)
          template.safe_join(
            week.map do |day|
              in_month = day.month == date.month
              template.content_tag(:div, role: "gridcell") do
                template.content_tag(
                  :button,
                  day.day.to_s,
                  tabindex: -1,
                  aria: { current: in_month ? "date" : nil },
                  data: { date: day.iso8601 }
                )
              end
            end
          )
        end
      end
    end
  end
end
