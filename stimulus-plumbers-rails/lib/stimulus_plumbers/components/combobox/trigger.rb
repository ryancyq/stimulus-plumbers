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
          data: {},
          **_rest
        )
          base_data = {
            "#{stimulus_controller}_target": "trigger",
            input_format_target:             "input",
            action:                          "focus->#{stimulus_controller}#open keydown.esc->#{stimulus_controller}#close"
          }

          aria = { haspopup: haspopup, expanded: "false", controls: popover_id }
          aria[:autocomplete] = aria_autocomplete if aria_autocomplete
          aria[:label]        = aria_label        if aria_label

          template.tag.input(
            type:     "text",
            readonly: (readonly ? true : nil),
            role:     "combobox",
            aria:     aria,
            data:     merge_data_options(base_data, data.symbolize_keys)
          )
        end
      end
    end
  end
end
