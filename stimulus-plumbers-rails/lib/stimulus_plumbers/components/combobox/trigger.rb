# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Trigger < Plumber::Base
        def render(
          stimulus_controller:,
          popover_id:,
          haspopup:,
          readonly: true,
          aria_autocomplete: nil,
          aria_label: nil,
          aria: {},
          id: nil,
          data: {},
          **kwargs
        )
          stimulus_data = {
            "#{stimulus_controller}_target": "trigger",
            input_formatter_target:          "input",
            action:                          "focus->#{stimulus_controller}#open keydown.esc->#{stimulus_controller}#close"
          }

          trigger_aria = { haspopup: haspopup, expanded: "false", controls: popover_id }
          trigger_aria[:autocomplete] = aria_autocomplete if aria_autocomplete
          trigger_aria[:label]        = aria_label        if aria_label

          template.tag.input(
            **merge_html_options(
              { classes: theme.resolve(:combobox_trigger).fetch(:classes, "") },
              {
                id:       id,
                type:     "text",
                readonly: (readonly ? true : nil),
                role:     "combobox",
                aria:     trigger_aria.deep_merge(aria),
                data:     merge_data_options(stimulus_data, data)
              },
              kwargs
            )
          )
        end
      end
    end
  end
end
