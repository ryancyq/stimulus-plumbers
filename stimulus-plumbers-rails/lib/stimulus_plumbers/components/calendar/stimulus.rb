# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      # Stimulus navigation: the header, empty grid, and cell templates the controller draws; hidden until drawn.
      class Stimulus < Plumber::Base
        def render(view)
          template.safe_join(
            [
              template.content_tag(:div, id: Calendar.frame_id_for(view.configuration.id), hidden: true) do
                template.safe_join([header(view), grid(view)])
              end,
              cell_templates
            ]
          )
        end

        private

        def header(view)
          template.content_tag(:div, **merge_html_options(theme.resolve(:calendar_header))) do
            template.safe_join(
              [
                step_button("previous", "chevron-left"),
                template.content_tag(:h2, nil, **merge_html_options(theme.resolve(:calendar_heading), { id: view.heading_id })),
                navigation_button("zoom"),
                step_button("next", "chevron-right")
              ]
            )
          end
        end

        def step_button(name, icon)
          navigation_button(name) { Icon.new(template).render(icon, aria: { hidden: "true" }) }
        end

        def navigation_button(name, &block)
          template.content_tag(
            :button,
            block ? template.capture(&block) : nil,
            type: "button",
            **merge_html_options(theme.resolve(:calendar_navigation), { data: { navigation: name } })
          )
        end

        def grid(view)
          template.content_tag(
            :table,
            nil,
            **merge_html_options(
              theme.resolve(:calendar_grid),
              {
                role: "grid",
                aria: { labelledby: view.heading_id },
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
