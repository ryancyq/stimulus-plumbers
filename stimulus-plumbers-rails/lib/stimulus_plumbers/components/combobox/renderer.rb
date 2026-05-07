# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Combobox
      class Renderer < Plumber::Base
        STIMULUS_CONTROLLER = "input-combobox"
        FORMAT_CONTROLLER   = "input-format"
        FORMAT_ACTION       = "input-combobox:changed->input-format#format"

        def render(base_id:, options: {}, **kwargs)
          popover_id    = "#{base_id}_popover"
          initial_value = options.dig(:input, :value)

          base_data = {
            controller: "#{STIMULUS_CONTROLLER} #{FORMAT_CONTROLLER}",
            action:     FORMAT_ACTION
          }
          base_data[:input_combobox_value_value] = initial_value if initial_value.present?

          html_options = merge_html_options({ data: base_data }, kwargs)

          template.content_tag(:div, **html_options) do
            template.safe_join(
              [
                trigger_input(
                  popover_id,
                  options.dig(:popover, :haspopup) || options.dig(:popover, :role) || "dialog",
                  options.fetch(:trigger, {})
                ),
                hidden_input(options.fetch(:input, {})),
                popover_element(popover_id, options.fetch(:popover, {}))
              ]
            )
          end
        end

        private

        def trigger_input(popover_id, haspopup, opts)
          base_data = {
            "#{STIMULUS_CONTROLLER}_target": "trigger",
            input_format_target:             "input",
            action:                          "focus->#{STIMULUS_CONTROLLER}#open keydown.esc->#{STIMULUS_CONTROLLER}#close"
          }
          data = merge_data_options(base_data, opts.fetch(:data, {}).symbolize_keys)

          aria = { haspopup: haspopup, expanded: "false", controls: popover_id }
          aria[:autocomplete] = opts[:aria_autocomplete] if opts[:aria_autocomplete]
          aria[:label]        = opts[:aria_label]        if opts[:aria_label]

          template.tag.input(
            type:     "text",
            readonly: (opts.fetch(:readonly, true) ? true : nil),
            role:     "combobox",
            aria:     aria,
            data:     data
          )
        end

        def hidden_input(opts)
          data = { "#{STIMULUS_CONTROLLER}_target": "value" }.merge(opts.fetch(:data, {}))
          template.tag.input(type: "hidden", name: opts[:name], value: opts[:value], data: data)
        end

        def popover_element(popover_id, opts)
          base_data = { "#{STIMULUS_CONTROLLER}_target": "popover" }
          data = merge_data_options(base_data, (opts[:data] || {}).symbolize_keys)

          attrs = { id: popover_id, hidden: "", data: data }
          attrs[:role] = opts[:role] if opts[:role]
          attrs[:aria] = { label: opts[:label] } if opts[:label]
          template.content_tag(opts.fetch(:tag, :div), **attrs) { opts[:content] }
        end
      end
    end
  end
end
