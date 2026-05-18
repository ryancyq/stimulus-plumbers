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
          data: {},
          **_rest
        )
          base_data = {
            "#{stimulus_controller}_target": "trigger",
            input_format_target:             "input",
            action:                          "focus->#{stimulus_controller}#open keydown.esc->#{stimulus_controller}#close"
          }

          built_aria = { haspopup: haspopup, expanded: "false", controls: popover_id }
          built_aria[:autocomplete] = aria_autocomplete if aria_autocomplete
          built_aria[:label]        = aria_label        if aria_label
          built_aria.merge!(aria)

          html_options = merge_html_options(
            { classes: theme.resolve(:combobox_trigger).fetch(:classes, "") },
            { type: "text", readonly: (readonly ? true : nil), role: "combobox", aria: built_aria,
              data: merge_data_options(base_data, data.symbolize_keys)
}
          )
          template.tag.input(**html_options)
        end
      end
    end
  end
end
