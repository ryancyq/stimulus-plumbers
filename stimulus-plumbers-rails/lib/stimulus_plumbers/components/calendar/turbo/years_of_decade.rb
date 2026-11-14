# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class Turbo
        class YearsOfDecade < Grid
          COLUMNS = 4

          # The decade plus one year either side.
          def rows
            @rows ||= ((first_year - 1)..(first_year + 10)).map { |year| Date.new(year, 1, 1) }.each_slice(COLUMNS).to_a
          end

          def heading
            I18n.t("stimulus_plumbers.calendar.decade_heading", first: first_year, last: first_year + 9)
          end

          def level
            :decade
          end

          def step(direction)
            configuration.displayed.beginning_of_year >> (120 * direction)
          end

          def zoom_in
            :year
          end

          private

          def first_year
            configuration.displayed.year - (configuration.displayed.year % 10)
          end

          def target
            "period"
          end

          def render_control(date, tabindex)
            period_control(date.year.to_s, date, tabindex)
          end

          # Named by its visible text.
          def label(_date)
            nil
          end

          def disabled?(date)
            configuration.availability.year_disabled?(date.year) || period_url(date).nil?
          end

          def unit(date)
            date.beginning_of_year
          end

          def outside?(date)
            date.year < first_year || date.year > first_year + 9
          end
        end
      end
    end
  end
end
