# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Combobox
      class Renderer < Plumber::Base
        STIMULUS_CONTROLLER = "input-combobox"

        def render(base_id:, options: {}, **kwargs)
          popover_id   = "#{base_id}_popover"
          popover_role = options.dig(:popover, :role) || "dialog"
          html_options = merge_html_options(
            { data: { controller: STIMULUS_CONTROLLER } },
            kwargs
          )
          template.content_tag(:div, **html_options) do
            template.safe_join(
              [
                trigger_input(popover_id, popover_role, options.fetch(:trigger, {})),
                hidden_input(options.fetch(:input, {})),
                popover_element(popover_id, options.fetch(:popover, {}))
              ]
            )
          end
        end

        private

        def trigger_input(popover_id, haspopup, opts)
          data = {
            "#{STIMULUS_CONTROLLER}_target": "trigger",
            action:                          "focus->#{STIMULUS_CONTROLLER}#open keydown.esc->#{STIMULUS_CONTROLLER}#close"
          }.merge(opts.fetch(:data, {}))

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
          attrs = {
            id:     popover_id,
            role:   opts.fetch(:role, "dialog"),
            hidden: "",
            data:   { "#{STIMULUS_CONTROLLER}_target": "popover" }
          }
          attrs[:aria] = { label: opts[:label] } if opts[:label]
          template.content_tag(opts.fetch(:tag, :div), **attrs) { opts[:content] }
        end
      end
    end
  end
end
