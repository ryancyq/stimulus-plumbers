# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Choice
          def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
            options[:layout] ||= :inline
            Field.new(@template, **options).render(
              object,
              attribute,
              input_id: field_id(attribute)
            ) do |html_opts, opts, error|
              html_options = merge_html_options(opts, html_opts, field_theme(:form_checkbox, error: error))
              super(attribute, html_options, checked_value, unchecked_value)
            end
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
            options[:layout] ||= :inline
            field = Field.new(@template, **options)
            render_fieldset(attribute, field) do |error|
              item_opts = merge_html_options(html_options, field_theme(:form_checkbox, error: error))
              super(attribute, collection, value_method, text_method, {}, item_opts, &block)
            end
          end

          def radio_button(attribute, tag_value, options = {})
            options[:layout] ||= :inline
            Field.new(@template, **options).render(
              object,
              attribute,
              input_id: field_id(attribute, tag_value)
            ) do |html_opts, opts, error|
              html_options = merge_html_options(opts, html_opts, field_theme(:form_radio, error: error))
              super(attribute, tag_value, html_options)
            end
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
            options[:layout] ||= :inline
            field = Field.new(@template, **options)
            render_fieldset(attribute, field) do |error|
              item_opts = merge_html_options(html_options, field_theme(:form_radio, error: error))
              super(attribute, collection, value_method, text_method, {}, item_opts, &block)
            end
          end
        end
      end
    end
  end
end
