# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Radio
          def radio_button(attribute, tag_value, options = {})
            html_options = merge_html_options(theme.resolve(:form_field_input_radio), options)
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
            item_opts = merge_html_options(theme.resolve(:form_field_input_radio), html_options)
            if block_given?
              super(attribute, collection, value_method, text_method, options, item_opts, &block)
            else
              super(attribute, collection, value_method, text_method, options, item_opts) do |builder|
                render_radio_button_label(builder, theme.resolve(:form_field_radio_label))
              end
            end
          end

          private

          def render_collection_radio_button(attribute, collection, value_method, text_method, field_opts, **kwargs)
            type    = kwargs.delete(:type)    { :default }
            variant = kwargs.delete(:variant) { :default }
            field = Field.new(@template, **{ layout: :inline }.deep_merge(field_opts))
            render_fieldset(attribute, field) do |error|
              item_opts = merge_html_options(
                theme.resolve(:form_field_input_radio, error: error, type: type, variant: variant),
                kwargs,
                field.required ? { aria: { required: "true" } } : {}
              )
              @template.collection_radio_buttons(
                @object_name, attribute, collection, value_method, text_method, {}, item_opts
              ) do |builder|
                render_radio_button_label(builder, theme.resolve(:form_field_radio_label, type: type, variant: variant))
              end
            end
          end

          def render_radio_button_label(builder, label_opts)
            html_options = merge_html_options(label_opts)
            builder.label(**html_options) { @template.safe_join([builder.radio_button, builder.text]) }
          end
        end
      end
    end
  end
end
