# frozen_string_literal: true

require "action_view/version"

require_relative "../plumber/options/aria"
require_relative "../plumber/options/html"

require_relative "base"
require_relative "field"
require_relative "fields/renderer"
require_relative "fields/fieldset"
require_relative "fields/inputs/checkbox"
require_relative "fields/inputs/combobox"
require_relative "fields/inputs/datetime"
require_relative "fields/inputs/radio"
require_relative "fields/inputs/file"
require_relative "fields/inputs/password"
require_relative "fields/inputs/search"
require_relative "fields/inputs/select"
require_relative "fields/inputs/select/grouped"
require_relative "fields/inputs/select/timezone"
require_relative "fields/inputs/select/weekday"
require_relative "fields/inputs/submit"
require_relative "fields/inputs/text"
require_relative "fields/inputs/text_area"

module StimulusPlumbers
  module Form
    class Builder < ActionView::Helpers::FormBuilder
      include Plumber::Options::Html
      include Plumber::Options::Aria
      include Fields::Inputs::Checkbox
      include Fields::Inputs::Datetime
      include Fields::Inputs::Radio
      include Fields::Inputs::File
      include Fields::Inputs::Password
      include Fields::Inputs::Search
      include Fields::Inputs::Select
      include Fields::Inputs::Select::Grouped
      include Fields::Inputs::Select::Timezone
      include Fields::Inputs::Select::Weekday
      include Fields::Inputs::Submit
      include Fields::Inputs::Text
      include Fields::Inputs::TextArea

      def field(attribute, as:, **options)
        field_opts = options.slice(*Field::OPTIONS)
        input_opts = options.except(*Field::OPTIONS)
        render_field(as, attribute, field_opts, input_opts)
      end

      def collection_field(attribute, as:, collection:, value_method:, text_method:, **options)
        field_opts = options.slice(*Field::OPTIONS)
        input_opts = options.except(*Field::OPTIONS)
        render_collection_field(as, attribute, field_opts, collection, value_method, text_method, input_opts)
      end

      def choice(attribute, as:, collection: nil, value_method: nil, text_method: nil, **options)
        field_opts = options.slice(*Field::OPTIONS)
        input_opts = options.except(*Field::OPTIONS)
        render_choice_field(as, attribute, field_opts, collection, value_method, text_method, input_opts)
      end

      private

      def theme
        StimulusPlumbers.config.theme.current
      end

      def render_field(as, attribute, field_opts, input_opts)
        raise ArgumentError, "unknown field type: #{as.inspect}" unless Fields::Renderer::FIELD.key?(as)

        field = Field.new(@template, **field_opts)
        field.render(object, attribute, input_id: field_id(attribute)) do |html_opts, opts, error|
          Plumber::Dispatcher.build(
            Fields::Renderer::FIELD.fetch(as), attribute, html_opts, opts, error, **input_opts
          ).call(self)
        end
      end

      def render_collection_field(as, attribute, field_opts, collection, value_method, text_method, input_opts)
        raise ArgumentError, "unknown collection field type: #{as.inspect}" unless Fields::Renderer::COLLECTION.key?(as)

        Plumber::Dispatcher.build(
          Fields::Renderer::COLLECTION.fetch(as),
          attribute,
          collection,
          value_method,
          text_method,
          field_opts,
          **input_opts
        ).call(self)
      end

      def render_choice_field(as, attribute, field_opts, collection, value_method, text_method, input_opts)
        raise ArgumentError, "unknown choice type: #{as.inspect}" unless Fields::Renderer::CHOICE.key?(as)

        Plumber::Dispatcher.build(
          Fields::Renderer::CHOICE.fetch(as),
          attribute,
          collection,
          value_method,
          text_method,
          field_opts,
          **input_opts
        ).call(self)
      end

      def render_fieldset(attribute, field, &block)
        Fields::Fieldset.new(@template).render(object, attribute, field_id(attribute), field, &block)
      end

      def render_input_group(error:, leading: nil, trailing: nil, **wrapper_opts, &block)
        Components::InputGroup.new(@template).render(leading: leading, trailing: trailing, error: error, **wrapper_opts, &block)
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
