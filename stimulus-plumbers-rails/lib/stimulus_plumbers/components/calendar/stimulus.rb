# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      # Stimulus navigation: the header, empty grid, and cell templates the controller draws; hidden until drawn.
      class Stimulus < Plumber::Base
        def stimulus_data(configuration)
          {
            "calendar-displayed-value"         => configuration.displayed.iso8601,
            "calendar-view-value"              => configuration.view.to_s,
            "calendar-today-value"             => configuration.today.iso8601,
            "calendar-locale-value"            => I18n.locale.to_s.tr("_", "-"),
            "calendar-first-day-of-week-value" => configuration.first_day_of_week.to_s,
            "calendar-show-other-months-value" => configuration.show_other_months.to_s
          }
        end

        def render(configuration)
          template.safe_join(
            [
              template.content_tag(:div, id: configuration.frame_id, hidden: true) do
                template.safe_join([Header.new(template).render(configuration), grid(configuration)])
              end,
              cell_templates
            ]
          )
        end

        private

        def grid(configuration)
          template.content_tag(
            :table,
            nil,
            **merge_html_options(
              theme.resolve(:calendar_grid),
              {
                role: "grid",
                aria: { labelledby: configuration.heading_id },
                data: {
                  "#{STIMULUS_CONTROLLER}-target" => "grid",
                  action:                           "keydown->#{STIMULUS_CONTROLLER}#onKeydown"
                }
              }
            )
          )
        end

        def cell_templates
          template.safe_join(
            [
              cell_template("weekdayTemplate") { template.content_tag(:th, nil, **themed(:calendar_weekday)) },
              cell_template("cellTemplate") { template.content_tag(:td, nil, **themed(:calendar_cell)) },
              cell_template("dateTemplate") { date_cell }
            ]
          )
        end

        def date_cell
          template.content_tag(:td, **themed(:calendar_cell)) do
            template.content_tag(:button, nil, type: "button", **themed(:calendar_date))
          end
        end

        def cell_template(target, &block)
          template.content_tag(:template, data: { "#{STIMULUS_CONTROLLER}-target" => target }, &block)
        end

        def themed(key)
          merge_html_options(theme.resolve(key))
        end
      end
    end
  end
end
