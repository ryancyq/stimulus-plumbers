# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      class Turbo
        class DaysOfMonth < Grid
          DAYS_PER_WEEK = 7

          # Whole weeks covering the month, starting on first_day_of_week.
          def rows
            @rows ||= (grid_start..grid_end).each_slice(DAYS_PER_WEEK).to_a
          end

          def heading
            I18n.l(configuration.displayed, format: "%B %Y")
          end

          def view_name
            :month
          end

          # The month a year away, or nil outside 0001–9999.
          def neighbour_year(direction)
            date = step(direction * 12)
            date if (1..9999).cover?(date.year)
          end

          def step(direction)
            configuration.displayed.beginning_of_month >> direction
          end

          def zoom_out
            :year
          end

          private

          def grid_start
            first = configuration.displayed.beginning_of_month
            first - ((first.wday - configuration.first_day_of_week) % DAYS_PER_WEEK)
          end

          def grid_end
            last = configuration.displayed.end_of_month
            last + ((configuration.first_day_of_week + 6 - last.wday) % DAYS_PER_WEEK)
          end

          def target
            "day"
          end

          def grid_attrs
            merge_html_options(super, { aria: { readonly: configuration.selectable ? nil : "true" }.compact })
          end

          def render_head
            template.content_tag(:thead) do
              template.content_tag(:tr) { template.safe_join(rows.first.map { |date| weekday_header(date.wday) }) }
            end
          end

          def weekday_header(wday)
            template.content_tag(
              :th,
              I18n.t("date.abbr_day_names")[wday],
              **merge_html_options(
                theme.resolve(:calendar_weekday), { scope: "col", abbr: I18n.t("date.day_names")[wday] }
              )
            )
          end

          def cell_attrs(date)
            return { role: "gridcell" } unless configuration.selectable

            { role: "gridcell", aria: { selected: (configuration.selected == date).to_s } }
          end

          def render_control(date, tabindex)
            template.content_tag(:button, date.day.to_s, type: "button", **control_attrs(date, tabindex))
          end

          def label(date)
            I18n.l(date, format: :long)
          end

          def navigable?(date)
            super && (configuration.show_other_months || date.month == configuration.displayed.month)
          end

          def outside?(date)
            date.month != configuration.displayed.month
          end

          def disabled?(date)
            configuration.availability.disabled?(date)
          end
        end
      end
    end
  end
end
