# frozen_string_literal: true

require "action_view/version"

require_relative "field_component"
require_relative "fields/choice"
require_relative "fields/combobox"
require_relative "fields/file"
require_relative "fields/password"
require_relative "fields/renderer"
require_relative "fields/search"
require_relative "fields/select"
require_relative "fields/text"
require_relative "fields/text_area"
require_relative "fields/submit"
require_relative "../plumber/html_options"

module StimulusPlumbers
  module Form
    class Builder < ActionView::Helpers::FormBuilder
      include Plumber::HtmlOptions
      include Fields::Choice
      include Fields::Combobox
      include Fields::File
      include Fields::Password
      include Fields::Search
      include Fields::Select
      include Fields::Submit
      include Fields::Text
      include Fields::TextArea

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

      def build_input_group(input_tag, field, trailing:, **wrapper_opts)
        @template.content_tag(
          :div,
          input_tag.html_safe + trailing,
          class: field_theme(:form_input_group, error: field.error?)[:class],
          **wrapper_opts
        )
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

      # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      if ActionView.version < "7.0"
        # field_id was added in Rails 7.0, backports it to Rails 6.1.
        # https://github.com/rails/rails/blob/2d670320f7b02ae879545d5202f0633841b8f196/actionview/lib/action_view/helpers/form_helper.rb#L1777
        # https://github.com/rails/rails/blob/2d670320f7b02ae879545d5202f0633841b8f196/actionview/lib/action_view/helpers/form_tag_helper.rb#L101
        def field_id(method_name, *suffixes, namespace: @options[:namespace], index: @options[:index])
          object_name = @object_name.respond_to?(:model_name) ? @object_name.model_name.singular : @object_name

          sanitized_object_name = object_name.to_s.gsub(%r{\]\[|[^-a-zA-Z0-9:.]}, "_").delete_suffix("_")
          sanitized_method_name = method_name.to_s.delete_suffix("?")

          [
            namespace,
            sanitized_object_name.presence,
            (index unless sanitized_object_name.empty?),
            sanitized_method_name,
            *suffixes
          ].tap(&:compact!).join("_")
        end

        # field_name was added in Rails 7.0, backports it to Rails 6.1.
        # https://github.com/rails/rails/blob/2d670320f7b02ae879545d5202f0633841b8f196/actionview/lib/action_view/helpers/form_helper.rb#L1797
        # https://github.com/rails/rails/blob/2d670320f7b02ae879545d5202f0633841b8f196/actionview/lib/action_view/helpers/form_tag_helper.rb#L131
        def field_name(method_name, *method_names, multiple: false, index: @options[:index])
          object_name = @options.fetch(:as) { @object_name }

          names = method_names.map! { |name| "[#{name}]" }.join

          # a little duplication to construct fewer strings
          if object_name.blank?
            "#{method_name}#{names}#{"[]" if multiple}"
          elsif index
            "#{object_name}[#{index}][#{method_name}]#{names}#{"[]" if multiple}"
          else
            "#{object_name}[#{method_name}]#{names}#{"[]" if multiple}"
          end
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    end
  end
end
