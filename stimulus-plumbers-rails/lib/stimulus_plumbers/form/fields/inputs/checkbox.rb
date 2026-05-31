# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Checkbox
          def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
            html_options = merge_html_options(options, field_theme(:form_checkbox))
            super(attribute, html_options, checked_value, unchecked_value)
          end

          def collection_check_boxes(
            attribute,
            collection,
            value_method,
            text_method,
            options = {},
            html_options = {},
            &block
          )
            item_opts = merge_html_options(html_options, field_theme(:form_checkbox))
            if block_given?
              super(attribute, collection, value_method, text_method, options, item_opts, &block)
            else
              super(attribute, collection, value_method, text_method, options, item_opts) do |b|
                @template.safe_join([b.label(**field_theme(:form_collection_label)), b.check_box])
              end
            end
          end

          private

          def render_check_box(
            attribute,
            html_opts,
            opts,
            error,
            checked_value: "1",
            unchecked_value: "0",
            **kwargs
          )
            html_options = merge_html_options(opts, html_opts, kwargs, field_theme(:form_checkbox, error: error))
            @template.check_box(
              @object_name, attribute, objectify_options(html_options), checked_value, unchecked_value
            )
          end

          def render_collection_check_box(attribute, collection, value_method, text_method, field_opts, **kwargs)
            field = Field.new(@template, **field_opts)
            render_fieldset(attribute, field) do |error|
              item_opts = merge_html_options(
                kwargs,
                field_theme(:form_checkbox, error: error),
                field.required ? { aria: { required: "true" } } : {}
              )
              @template.collection_check_boxes(
                @object_name, attribute, collection, value_method, text_method, {}, item_opts
              ) do |b|
                @template.safe_join([b.label(**field_theme(:form_collection_label)), b.check_box])
              end
            end
          end
        end
      end
    end
  end
end
