# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Temporal
        # The read-only input with decorative icons; it opens the popover.
        class Trigger < Plumber::Base
          FOCUS_ACTION = "focus->#{Popover::STIMULUS_CONTROLLER}#onFocus".freeze

          def render(controller:, id:, value:, aria:, open_on_focus: true, icon_leading: nil, icon_trailing: nil, trigger: {})
            TriggerGroup.new(template).render(icon_leading: icon_leading, icon_trailing: icon_trailing) do
              template.tag.input(
                **merge_html_options(
                  theme.resolve(:combobox_trigger),
                  input_attrs(controller, id, value, aria, open_on_focus),
                  trigger
                )
              )
            end
          end

          private

          def input_attrs(controller, id, value, aria, open_on_focus)
            actions = ["click->#{Popover::STIMULUS_CONTROLLER}#open", "keydown->#{controller}#onKeydown"]
            actions.unshift(FOCUS_ACTION) if open_on_focus
            {
              id:           id,
              type:         "text",
              value:        value,
              readonly:     true,
              inputmode:    "none",
              autocomplete: "off",
              role:         "combobox",
              aria:         aria,
              data:         {
                popover_target:                      "trigger",
                "#{controller}-target"            => "trigger",
                "#{FORMAT_CONTROLLER}-target"     => "input",
                action:                              actions.join(" ")
              }
            }
          end
        end
      end
    end
  end
end
