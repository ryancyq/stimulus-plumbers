# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ComboboxHelper
      def sp_combobox_date(record = nil, attribute = nil, name: nil, value: nil, **html_options)
        base_id     = sp_dom_id(record, attribute&.to_s)
        calendar_id = "#{base_id}_calendar"
        popover_id  = "#{base_id}_popover"
        ids = { calendar_id: calendar_id, popover_id: popover_id }

        resolved_name = name || [record&.model_name&.param_key, attribute].filter(&:presence).join("[").then do |s|
          s.empty? ? base_id : "#{s}]"
        end
        resolved_value = value || record&.public_send(attribute)

        content = Components::Combobox::Date.new(self).render(**ids)
        Components::Combobox::Renderer.new(self).render(
          name:          resolved_name,
          value:         resolved_value,
          content:       content,
          popover_id:    popover_id,
          popover_role:  "dialog",
          popover_tag:   :div,
          popover_label: "Picker",
          trigger_data:  { input_datepicker_target: "display" },
          value_data:    { input_datepicker_target: "input" },
          **html_options
        )
      end

      def sp_combobox_dropdown(record = nil, attribute = nil, options: [], name: nil, value: nil, **html_options)
        base_id    = sp_dom_id(record, attribute&.to_s)
        popover_id = "#{base_id}_popover"
        ids = { popover_id: popover_id }

        resolved_name = name || [record&.model_name&.param_key, attribute].filter(&:presence).join("[").then do |s|
          s.empty? ? base_id : "#{s}]"
        end
        resolved_value = value || record&.public_send(attribute)

        content = Components::Combobox::Dropdown.new(self).render(**ids, options: options, value: resolved_value)
        Components::Combobox::Renderer.new(self).render(
          name:         resolved_name,
          value:        resolved_value,
          content:      content,
          popover_id:   popover_id,
          popover_role: "listbox",
          popover_tag:  :ul,
          **html_options
        )
      end

      def sp_combobox_autocomplete(record = nil, attribute = nil, options: [], name: nil, value: nil, **html_options)
        base_id    = sp_dom_id(record, attribute&.to_s)
        popover_id = "#{base_id}_popover"
        ids = { popover_id: popover_id }

        resolved_name = name || [record&.model_name&.param_key, attribute].filter(&:presence).join("[").then do |s|
          s.empty? ? base_id : "#{s}]"
        end
        resolved_value = value || record&.public_send(attribute)

        content = Components::Combobox::Autocomplete.new(self).render(**ids, options: options, value: resolved_value)
        Components::Combobox::Renderer.new(self).render(
          name:              resolved_name,
          value:             resolved_value,
          content:           content,
          popover_id:        popover_id,
          popover_role:      "listbox",
          popover_tag:       :ul,
          trigger_readonly:  false,
          aria_autocomplete: "list",
          **html_options
        )
      end

      def sp_combobox_time(record = nil, attribute = nil, name: nil, value: nil, format: :h12, step: 1, **html_options)
        base_id = sp_dom_id(record, attribute&.to_s)
        popover_id = "#{base_id}_popover"
        ids = { popover_id: popover_id }

        resolved_name = name || [record&.model_name&.param_key, attribute].filter(&:presence).join("[").then do |s|
          s.empty? ? popover_id : "#{s}]"
        end
        resolved_value = value || record&.public_send(attribute)

        content = Components::Combobox::Time.new(self).render(**ids, value: resolved_value, format: format, step: step)
        Components::Combobox::Renderer.new(self).render(
          name:          resolved_name,
          value:         resolved_value,
          content:       content,
          popover_id:    popover_id,
          popover_role:  "dialog",
          popover_tag:   :div,
          popover_label: "Picker",
          trigger_data:  { input_timepicker_target: "display" },
          value_data:    { input_timepicker_target: "input" },
          **html_options
        )
      end
    end
  end
end
