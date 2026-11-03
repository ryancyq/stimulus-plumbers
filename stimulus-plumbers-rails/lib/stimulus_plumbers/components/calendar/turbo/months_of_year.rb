# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class Turbo
        class MonthsOfYear < Grid
          COLUMNS = 4

          def rows
            @rows ||= (1..12).map { |month| Date.new(configuration.displayed.year, month, 1) }.each_slice(COLUMNS).to_a
          end

          def heading
            configuration.displayed.year.to_s
          end

          def view_name
            :year
          end

          def step(direction)
            configuration.displayed.beginning_of_year >> (12 * direction)
          end

          def zoom_out
            :decade
          end

          private

          def target
            "period"
          end

          # Links to the month; an unavailable month has no href.
          def render_control(date, tabindex)
            text = I18n.l(date, format: "%B")
            return template.content_tag(:a, text, role: "link", **control_attrs(date, tabindex)) if disabled?(date)

            template.link_to(text, link.call(date, :month), **control_attrs(date, tabindex))
          end

          def label(date)
            I18n.l(date, format: "%B %Y")
          end

          def disabled?(date)
            configuration.availability.month_disabled?(date.year, date.month)
          end

          def unit(date)
            date.beginning_of_month
          end
        end
      end
    end
  end
end
