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

      def render_fieldset(attribute, field, &block)
        Fields::Fieldset.new(@template).render(object, attribute, field_id(attribute), field, &block)
      end

      def render_input_group(error:, leading: nil, trailing: nil, **wrapper_opts, &block)
        Fields::InputGroup.new(@template).render(leading: leading, trailing: trailing, error: error, **wrapper_opts, &block)
      end

      def render_combobox(attribute, input_id:, opts:, err:, **wrapper_opts, &block)
        combobox_opts = opts.deep_merge(
          input:   { name: field_name(attribute) },
          trigger: { id: input_id }
        )

        Components::Combobox.new(@template).render(
          **combobox_opts,
          **merge_html_options(wrapper_opts, field_theme(:form_combobox, error: err)),
          &block
        )
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
