# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ComboboxHelper
      # Renders a standalone date combobox (trigger input + calendar popup).
      # Generates stable IDs from the record/attribute pair when provided,
      # falling back to random IDs for standalone use.
      #
      # @param record [Object, nil] model object (for stable ID generation)
      # @param attribute [Symbol, String, nil] attribute name
      # @param name [String] HTML name for the hidden value input
      # @param value [String, nil] current ISO date value (YYYY-MM-DD or ISO 8601)
      # @param html_options [Hash] forwarded to the combobox wrapper element
      #
      # @example With a record
      #   sp_combobox_date(user, :birthday)
      #
      # @example Standalone filter
      #   sp_combobox_date(name: "filter[date]", value: params[:date])
      def sp_combobox_date(record = nil, attribute = nil, name: nil, value: nil, **html_options)
        calendar_id = sp_dom_id(record, [attribute, "calendar"].filter(&:presence).join("_"))
        popup_id    = "#{calendar_id}_popup"
        ids         = { calendar_id: calendar_id, popup_id: popup_id }

        resolved_name  = name || [record&.model_name&.param_key, attribute].filter(&:presence).join("[").then { |s| s.empty? ? calendar_id : "#{s}]" }
        resolved_value = value || record&.public_send(attribute)

        content = Components::Combobox::Date.new(self).render(**ids)
        Components::Combobox::Renderer.new(self).render(
          name:         resolved_name,
          value:        resolved_value,
          content:      content,
          popup_id:     popup_id,
          trigger_data: { input_datepicker_target: "display" },
          value_data:   { input_datepicker_target: "input" },
          **html_options
        )
      end
    end
  end
end
