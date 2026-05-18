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

      def error_ids
        return [] if errors.none?
        return [error_id] if errors.one?

        errors.each_index.map { |i| "#{error_id}_#{i + 1}" }
      end

      def described_by
        ids = []
        ids << hint_id if details.present?
        ids.concat(error_ids)
        ids.join(" ").presence
      end

      def label_hidden?
        label_visibility == :exclusive
      end

      def render(template, theme, input_html)
        Fields::Group.new(template).render(layout: layout, error: error?) do
          (field_label(template) + input_html.html_safe + field_hint(template) + field_errors(template)).html_safe
        end
      end

      private

      def field_label(template)
        Fields::Label.new(template).render(
          text:     label_text,
          for_id:   input_id,
          required: required,
          hidden:   label_hidden?
        )
      end

      def field_hint(template)
        return "".html_safe unless details.present?

        Fields::Hint.new(template).render(text: details, id: hint_id)
      end

      def field_errors(template)
        return "".html_safe if errors.none?

        errors.map.with_index do |message, i|
          Fields::Error.new(template).render(message: message, id: error_ids[i])
        end.join.html_safe
      end
    end
  end
end
