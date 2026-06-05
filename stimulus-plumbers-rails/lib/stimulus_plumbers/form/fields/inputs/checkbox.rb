# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Checkbox
          def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
            html_options = merge_html_options(theme.resolve(:form_checkbox), options)
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
            item_opts = merge_html_options(theme.resolve(:form_checkbox), html_options)
            if block_given?
              super(attribute, collection, value_method, text_method, options, item_opts, &block)
            else
              super(attribute, collection, value_method, text_method, options, item_opts) do |builder|
                render_check_box_label(builder, theme.resolve(:form_checkbox_label))
              end
            end
          end

          private

          def render_check_box(attribute, collection, value_method, text_method, field_opts, **kwargs)
            if collection
              render_collection_check_box(attribute, collection, value_method, text_method, field_opts, **kwargs)
            else
              render_single_check_box(attribute, field_opts, **kwargs)
            end
          end

          def render_collection_check_box(attribute, collection, value_method, text_method, field_opts, **kwargs)
            type    = kwargs.delete(:type)    { :default }
            variant = kwargs.delete(:variant) { :default }
            field   = Field.new(@template, **{ layout: :inline }.deep_merge(field_opts))
            render_fieldset(attribute, field) do |error|
              item_opts = merge_html_options(
                theme.resolve(:form_checkbox, error: error, type: type, variant: variant),
                kwargs,
                field.required ? { aria: { required: "true" } } : {}
              )
              @template.collection_check_boxes(
                @object_name, attribute, collection, value_method, text_method, {}, item_opts
              ) do |builder|
                render_check_box_label(builder, theme.resolve(:form_checkbox_label, type: type, variant: variant), type)
              end
            end
          end

          def render_check_box_label(builder, label_opts, type = :default)
            html_options = merge_html_options(label_opts)
            case type
            when :card
              builder.label(**html_options) { @template.safe_join([builder.text, builder.check_box]) }
            else
              builder.label(**html_options) { @template.safe_join([builder.check_box, builder.text]) }
            end
          end

          def render_single_check_box(attribute, field_opts, checked_value: "1", unchecked_value: "0", **kwargs)
            field    = Field.new(@template, **field_opts)
            input_id = field_id(attribute)
            error    = field.error?(object, attribute)

            Fields::Group.new(@template).render(layout: :stacked, error: error) do
              check_box_html = build_check_box_input(field, attribute, input_id, error, checked_value, unchecked_value, **kwargs)
              @template.safe_join([
                build_check_box_label(field, attribute, input_id, check_box_html),
                field.render_hint(input_id),
                field.render_errors(object, attribute, input_id)
              ])
            end
          end

          def build_check_box_input(field, attribute, input_id, error, checked_value, unchecked_value, **kwargs)
            check_box_opts = merge_html_options(
              theme.resolve(:form_checkbox, error: error),
              kwargs,
              {
                id:   input_id,
                aria: {
                  describedby: field.described_by(object, attribute, input_id),
                  invalid:     error ? "true" : nil,
                  required:    field.required ? "true" : nil
                }.compact
              },
              field.required ? { required: true } : {}
            )
            @template.check_box(@object_name, attribute, objectify_options(check_box_opts), checked_value, unchecked_value)
          end

          def build_check_box_label(field, attribute, input_id, check_box_html)
            label_opts = merge_html_options(theme.resolve(:form_checkbox_label))
            label_text = field.label || attribute.to_s.humanize
            @template.content_tag(:label, for: input_id, **label_opts) do
              @template.safe_join([check_box_html, label_text])
            end
          end
        end
      end
    end
  end
end
