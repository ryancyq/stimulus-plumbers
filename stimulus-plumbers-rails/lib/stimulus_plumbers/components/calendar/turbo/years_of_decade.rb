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

          def view_name
            :decade
          end

          def step(direction)
            configuration.displayed.beginning_of_year >> (120 * direction)
          end

          private

          def first_year
            configuration.displayed.year - (configuration.displayed.year % 10)
          end

          def target
            "period"
          end

          # Links to the year; an unavailable year has no href.
          def render_control(date, tabindex)
            text = date.year.to_s
            return template.content_tag(:a, text, role: "link", **control_attrs(date, tabindex)) if disabled?(date)

            template.link_to(text, link.call(date, :year), **control_attrs(date, tabindex))
          end

          # Named by its visible text.
          def label(_date)
            nil
          end

          def disabled?(date)
            configuration.availability.year_disabled?(date.year)
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
