# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Combobox
      class Renderer < Plumber::Base
        STIMULUS_CONTROLLER = "input-combobox"

        def render(
          content:,
          name:,
          popover_id:,
          aria_autocomplete: nil,
          popover_label: nil,
          popover_role: "dialog",
          popover_tag: :div,
          trigger_data: {},
          trigger_readonly: true,
          value: nil,
          value_data: {},
          **kwargs
        )
          html_options = merge_html_options(
            { data: { controller: STIMULUS_CONTROLLER } },
            kwargs
          )
          template.content_tag(:div, **html_options) do
            template.safe_join(
              [
                trigger_input(popover_id, popover_role, aria_autocomplete, trigger_readonly, trigger_data),
                hidden_input(name, value, value_data),
                popover_element(content, popover_id, popover_role, popover_tag, popover_label)
              ]
            )
          end
        end

        private

        def trigger_input(popover_id, haspopup, aria_autocomplete, readonly, extra_data)
          data = {
            "#{STIMULUS_CONTROLLER}_target": "trigger",
            action:                          "focus->#{STIMULUS_CONTROLLER}#open keydown.esc->#{STIMULUS_CONTROLLER}#close"
          }.merge(extra_data)

          aria = { haspopup: haspopup, expanded: "false", controls: popover_id }
          aria[:autocomplete] = aria_autocomplete if aria_autocomplete

          template.tag.input(
            type:     "text",
            readonly: (readonly ? true : nil),
            role:     "combobox",
            aria:     aria,
            data:     data
          )
        end

        def hidden_input(name, value, extra_data)
          data = { "#{STIMULUS_CONTROLLER}_target": "value" }.merge(extra_data)
          template.tag.input(type: "hidden", name: name, value: value, data: data)
        end

        def popover_element(content, popover_id, role, tag, label)
          options = {
            id:     popover_id,
            role:   role,
            hidden: "",
            data:   { "#{STIMULUS_CONTROLLER}_target": "popover" }
          }
          options[:aria] = { label: label } if label
          template.content_tag(tag, **options) { content }
        end
      end
    end
  end
end
