# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module DatePicker
      class Renderer < Plumber::Base
        STIMULUS_CONTROLLER = "datepicker"
        POPOVER_CONTROLLER  = "popover"
        CALENDAR_CONTROLLER = Calendar::Renderer::OBSERVER_STIMULUS_CONTROLLER
        CALENDAR_OUTLET     = "#{STIMULUS_CONTROLLER}_#{Calendar::Renderer::STIMULUS_CONTROLLER}_outlet".freeze
        STIMULUS_DATA       = {
          controller: "#{STIMULUS_CONTROLLER} #{POPOVER_CONTROLLER}",
          action:     "#{CALENDAR_CONTROLLER}:selected->#{STIMULUS_CONTROLLER}#selected " \
                      "#{CALENDAR_CONTROLLER}:selected->#{POPOVER_CONTROLLER}#hide"
        }.freeze

        def render(calendar_dialog_id: nil, calendar_id: nil, **kwargs)
          data         = calendar_id ? STIMULUS_DATA.merge(CALENDAR_OUTLET => "##{calendar_id}") : STIMULUS_DATA
          html_options = merge_html_options(
            { classes: theme.resolve(:datepicker).fetch(:classes, ""), data: data },
            kwargs
          )

          template.content_tag(:div, **html_options) do
            template.safe_join([display_input(calendar_dialog_id), hidden_input, popover(calendar_id, calendar_dialog_id)])
          end
        end

        private

        def display_input(calendar_dialog_id)
          template.tag.input(
            type: "text",
            role: "combobox",
            aria: { label: "Date", haspopup: "dialog", controls: calendar_dialog_id },
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

        def popover(calendar_id, calendar_dialog_id)
          template.content_tag(
            :div,
            id:     calendar_dialog_id,
            role:   "dialog",
            aria:   { label: "Date picker" },
            data:   { "#{POPOVER_CONTROLLER}_target": "content" },
            hidden: ""
          ) do
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
