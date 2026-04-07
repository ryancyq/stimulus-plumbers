# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module DatePicker
      class Renderer < Plumber::Base
        STIMULUS_CONTROLLER = "datepicker"
        POPOVER_CONTROLLER  = "popover"
        CALENDAR_CONTROLLER = Calendar::Renderer::OBSERVER_STIMULUS_CONTROLLER
        CALENDAR_OUTLET     = "#{STIMULUS_CONTROLLER}_#{Calendar::Renderer::STIMULUS_CONTROLLER}_outlet"
        STIMULUS_DATA       = {
          controller: "#{STIMULUS_CONTROLLER} #{POPOVER_CONTROLLER}",
          action:     "#{CALENDAR_CONTROLLER}:selected->#{STIMULUS_CONTROLLER}#selected " \
                      "#{CALENDAR_CONTROLLER}:selected->#{POPOVER_CONTROLLER}#hide"
        }.freeze

        def render(calendar_id: nil, **kwargs)
          data         = calendar_id ? STIMULUS_DATA.merge(CALENDAR_OUTLET => "##{calendar_id}") : STIMULUS_DATA
          html_options = merge_html_options(
            { classes: theme.resolve(:datepicker).fetch(:classes, ""), data: data },
            **kwargs
          )

          template.content_tag(:div, **html_options) do
            template.safe_join([display_input, hidden_input, popover(calendar_id)])
          end
        end

        private

        def display_input
          template.tag.input(
            type: "text",
            aria: { label: "Date" },
            data: {
              "#{STIMULUS_CONTROLLER}_target": "display",
              "#{POPOVER_CONTROLLER}_target":  "activator",
              action:                          [
                "focus->#{POPOVER_CONTROLLER}#show",
                "click->#{POPOVER_CONTROLLER}#show"
              ].join(" ")
            }
          )
        end

        def hidden_input
          template.tag.input(
            type: "hidden",
            data: { "#{STIMULUS_CONTROLLER}_target": "input" }
          )
        end

        def popover(calendar_id)
          template.content_tag(:div, data: { "#{POPOVER_CONTROLLER}_target": "content" }, hidden: "") do
            template.safe_join(
              [
                navigation(stimulus_controller: STIMULUS_CONTROLLER, step: "month"),
                calendar_month(id: calendar_id)
              ]
            )
          end
        end

        def navigation(**kwargs)
          Navigation.new(template).render(stimulus_controller: STIMULUS_CONTROLLER, step: "month", **kwargs)
        end

        def calendar_month(**kwargs)
          Calendar::Renderer.new(template).month(**kwargs)
        end
      end
    end
  end
end
