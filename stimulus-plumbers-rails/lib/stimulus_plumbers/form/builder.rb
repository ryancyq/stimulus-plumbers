# frozen_string_literal: true

require_relative "field_component"
require_relative "fields/renderer"
require_relative "fields/text"
require_relative "fields/text_area"
require_relative "fields/file"
require_relative "fields/select"
require_relative "fields/choice"

module StimulusPlumbers
  module Form
    class Builder < ActionView::Helpers::FormBuilder
      include Fields::Text
      include Fields::TextArea
      include Fields::File
      include Fields::Select
      include Fields::Choice

      private

      def build_field(attribute, form_field_opts, input_id: field_id(attribute))
        FieldComponent.new(
          object:           object,
          attribute:        attribute,
          input_id:         input_id,
          label:            form_field_opts[:label],
          details:          form_field_opts[:details],
          error:            form_field_opts[:error],
          required:         form_field_opts.fetch(:required, false),
          label_visibility: form_field_opts.fetch(:label_visibility, :visible),
          layout:           form_field_opts.fetch(:layout, :stacked)
        )
      end

      def render_field(field, input_html)
        Fields::Renderer.new(@template, theme, field).call(input_html)
      end

      def extract_options(options)
        [options.except(*FieldComponent::OPTIONS), options.slice(*FieldComponent::OPTIONS)]
      end

      def field_theme(key, **variants)
        { class: theme.resolve(key, **variants).fetch(:classes, "") }
      end

      def theme
        StimulusPlumbers.config.theme
      end
    end
  end
end
