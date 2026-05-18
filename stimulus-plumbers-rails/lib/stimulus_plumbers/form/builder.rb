# frozen_string_literal: true

require "action_view/version"

require_relative "field"
require_relative "fields/fieldset"
require_relative "fields/inputs/choice"
require_relative "fields/inputs/datetime"
require_relative "fields/inputs/file"
require_relative "fields/inputs/password"
require_relative "fields/inputs/search"
require_relative "fields/inputs/select"
require_relative "fields/inputs/submit"
require_relative "fields/inputs/text"
require_relative "fields/inputs/text_area"
require_relative "../plumber/html_options"

module StimulusPlumbers
  module Form
    class Builder < ActionView::Helpers::FormBuilder
      include Plumber::HtmlOptions
      include Fields::Inputs::Choice
      include Fields::Inputs::Datetime
      include Fields::Inputs::File
      include Fields::Inputs::Password
      include Fields::Inputs::Search
      include Fields::Inputs::Select
      include Fields::Inputs::Submit
      include Fields::Inputs::Text
      include Fields::Inputs::TextArea

      private

      def build_field(attribute, form_field_opts, input_id: field_id(attribute))
        Field.new(
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
        field.render(@template, theme, input_html)
      end

      def render_fieldset(field, inputs_html, **fieldset_opts)
        Fields::Fieldset.new(@template).render(field, inputs_html, **fieldset_opts)
      end

      def render_input_group(input_tag, field, trailing:, **wrapper_opts)
        Fields::InputGroup.new(@template).render(input_tag, trailing: trailing, error: field.error?, **wrapper_opts)
      end

      def render_combobox(attribute, field, opts, wrapper_data: {}, html_options: {}, &block)
        trigger_aria = field.error? ? { trigger: { aria: { invalid: "true" } } } : {}
        Components::Combobox.new(@template).render(
          base_id: field_id(attribute),
          options: opts.deep_merge(input: { name: field_name(attribute) }).deep_merge(trigger_aria),
          **merge_html_options(
            html_options,
            { data: wrapper_data },
            field_theme(:form_combobox, error: field.error?),
            field.html_options
          ),
          &block
        )
      end

      def extract_options(options)
        [options.except(*Field::OPTIONS), options.slice(*Field::OPTIONS)]
      end

      def field_theme(key, **variants)
        { class: theme.resolve(key, **variants).fetch(:classes, "") }
      end

      def theme
        StimulusPlumbers.config.theme.current
      end

      # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      if ActionView.version < Gem::Version.new("7.0")
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
