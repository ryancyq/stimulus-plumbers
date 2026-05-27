# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Radio
          def radio_button(attribute, tag_value, options = {})
            html_options = merge_html_options(options, field_theme(:form_radio))
            super(attribute, tag_value, html_options)
          end

          def collection_radio_buttons(
            attribute,
            collection,
            value_method,
            text_method,
            options = {},
            html_options = {},
            &block
          )
            item_opts = merge_html_options(html_options, field_theme(:form_radio))
            if block
              super(attribute, collection, value_method, text_method, options, item_opts, &block)
            else
              super(attribute, collection, value_method, text_method, options, item_opts) do |b|
                Fields::Choice.new(@template).render(label: b.text) { b.radio_button }
              end
            end
          end

          private

          def render_collection_radio_button(attribute, collection, value_method, text_method, field_opts, **input_opts)
            field = Field.new(@template, **field_opts)
            render_fieldset(attribute, field) do |error|
              item_opts = merge_html_options(input_opts, field_theme(:form_radio, error: error))
              @template.collection_radio_buttons(
                @object_name, attribute, collection, value_method, text_method, {}, item_opts
              ) do |b|
                Fields::Choice.new(@template).render(label: b.text) { b.radio_button }
              end
            end
          end
        end
      end
    end
  end
end
