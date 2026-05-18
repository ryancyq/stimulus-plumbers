# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          def select(attribute, choices = nil, options = {}, html_options = {})
            rails_opts, form_field_opts = extract_options(options)
            html_native = form_field_opts.delete(:html_native) { false }
            field       = build_field(attribute, form_field_opts)

            if html_native
              select_html = merge_html_options(html_options, field_theme(:form_select, error: field.error?), field.html_options)
              render_field(field, super(attribute, choices, rails_opts, select_html))
            else
              current_value = object&.public_send(attribute)
              opts = Components::Combobox::Dropdown.default_opts.deep_merge(input: { value: current_value })
              render_field(
                field,
                render_combobox(attribute, field, opts, html_options: html_options) do
                  Components::Combobox::Dropdown.new(@template).render(options: Array(choices), value: current_value)
                end
              )
            end
          end

          def collection_select(
            attribute,
            collection,
            value_method,
            text_method,
            options = {},
            html_options = {}
          )
            rails_opts, form_field_opts = extract_options(options)
            html_native = form_field_opts.delete(:html_native) { false }
            field       = build_field(attribute, form_field_opts)

            if html_native
              select_html = merge_html_options(html_options, field_theme(:form_select, error: field.error?), field.html_options)
              render_field(field, super(attribute, collection, value_method, text_method, rails_opts, select_html))
            else
              current_value = object&.public_send(attribute)
              choices       = collection.map { |item| [item.public_send(text_method), item.public_send(value_method)] }
              opts = Components::Combobox::Dropdown.default_opts.deep_merge(input: { value: current_value })
              render_field(
                field,
                render_combobox(attribute, field, opts, html_options: html_options) do
                  Components::Combobox::Dropdown.new(@template).render(options: choices, value: current_value)
                end
              )
            end
          end
        end
      end
    end
  end
end
