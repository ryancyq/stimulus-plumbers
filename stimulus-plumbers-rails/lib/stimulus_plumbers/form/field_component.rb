# frozen_string_literal: true

module StimulusPlumbers
  module Form
    class FieldComponent
      attr_reader :object,
                  :attribute,
                  :label_text,
                  :details,
                  :required,
                  :disabled,
                  :label_visibility,
                  :layout

      def initialize(object:, attribute:,
                     label: nil,
                     details: nil,
                     error: nil,
                     required: false,
                     disabled: false,
                     label_visibility: :visible,
                     layout: :stacked,
                     input_id: nil)
        @object           = object
        @attribute        = attribute
        @label_text       = label || attribute.to_s.humanize
        @details          = details
        @error_override   = error
        @required         = required
        @disabled         = disabled
        @label_visibility = label_visibility.to_sym
        @layout           = layout.to_sym
        @input_id_override = input_id
      end

      def errors
        if @error_override
          Array(@error_override)
        elsif object.respond_to?(:errors)
          object.errors[@attribute]
        else
          []
        end
      end

      def error?
        errors.any?
      end

      def input_id
        @input_id_override || "#{object.model_name.param_key}_#{attribute}"
      end

      def hint_id
        "#{input_id}_hint"
      end

      def error_id
        "#{input_id}_error"
      end

      def described_by
        ids = []
        ids << hint_id  if details.present?
        ids << error_id if errors.any?
        ids.join(" ").presence
      end

      def label_hidden?
        label_visibility == :exclusive
      end
    end
  end
end
