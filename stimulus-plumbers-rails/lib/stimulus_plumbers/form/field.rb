# frozen_string_literal: true

module StimulusPlumbers
  module Form
    class Field
      OPTIONS = %i[label details error required label_visibility layout reveal clearable html_native].freeze

      attr_reader :object,
                  :attribute,
                  :input_id,
                  :label_text,
                  :details,
                  :required,
                  :label_visibility,
                  :layout

      def initialize(
        object:,
        attribute:,
        input_id:,
        label: nil,
        details: nil,
        error: nil,
        required: false,
        label_visibility: :visible,
        layout: :stacked
      )
        @object           = object
        @attribute        = attribute
        @input_id         = input_id
        @label_text       = label || attribute.to_s.humanize
        @details          = details
        @error_override   = error
        @required         = required
        @label_visibility = label_visibility.to_sym
        @layout           = layout.to_sym
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

      def html_options
        attrs = { id: input_id }
        attrs[:"aria-describedby"] = described_by if described_by
        attrs[:"aria-invalid"]     = "true"       if error?
        attrs[:required]           = true         if required
        attrs[:"aria-required"]    = "true"       if required
        attrs
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
