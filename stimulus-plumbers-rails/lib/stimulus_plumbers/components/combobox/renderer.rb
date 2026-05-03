# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Combobox
      class Renderer < Plumber::Base
        STIMULUS_CONTROLLER = "input-combobox"

        # Renders the combobox shell: a trigger text input, a hidden value input,
        # and a popup wrapper containing the given content.
        #
        # @param name [String] HTML name attribute for the hidden value input
        # @param value [String, nil] current value for the hidden input
        # @param content [String] safe HTML string for the popup body
        # @param popup_id [String] id applied to the popup div (for aria-controls)
        # @param trigger_data [Hash] extra data attributes merged onto the trigger input
        # @param value_data [Hash] extra data attributes merged onto the hidden input
        def render(name:, value: nil, content:, popup_id:, trigger_data: {}, value_data: {}, **kwargs)
          html_options = merge_html_options(
            { data: { controller: STIMULUS_CONTROLLER } },
            kwargs
          )
          template.content_tag(:div, **html_options) do
            template.safe_join([
              trigger_input(popup_id, trigger_data),
              hidden_input(name, value, value_data),
              popup_div(content, popup_id)
            ])
          end
        end

        private

        def trigger_input(popup_id, extra_data)
          data = {
            "#{STIMULUS_CONTROLLER}_target": "trigger",
            action: "focus->#{STIMULUS_CONTROLLER}#open keydown.esc->#{STIMULUS_CONTROLLER}#close"
          }.merge(extra_data)

          template.tag.input(
            type: "text",
            readonly: true,
            role: "combobox",
            aria: { haspopup: "dialog", expanded: "false", controls: popup_id },
            data: data
          )
        end

        def hidden_input(name, value, extra_data)
          data = { "#{STIMULUS_CONTROLLER}_target": "value" }.merge(extra_data)
          template.tag.input(type: "hidden", name: name, value: value, data: data)
        end

        def popup_div(content, popup_id)
          template.content_tag(
            :div,
            id: popup_id,
            role: "dialog",
            aria: { label: "Picker" },
            hidden: "",
            data: { "#{STIMULUS_CONTROLLER}_target": "popup" }
          ) { content }
        end
      end
    end
  end
end
