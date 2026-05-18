# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Datetime
          def date_field(attribute, options = {})
            rails_opts, form_field_opts = extract_options(options)
            html_native = form_field_opts.delete(:html_native) { false }
            field       = build_field(attribute, form_field_opts)

            if html_native
              html_opts = merge_html_options(rails_opts, field_theme(:form_input, error: field.error?), field.html_options)
              render_field(field, super(attribute, html_opts))
            else
              current_value = object&.public_send(attribute)
              opts = Components::Combobox::Date.default_opts.deep_merge(
                input: {
                  value: current_value,
                  data:  { combobox_date_date_value: current_value }
                }
              )
              render_field(
                field,
                render_combobox(
                  attribute,
                  field,
                  opts,
                  wrapper_data: { input_format_type_value: "date" }
                ) { Components::Combobox::Date.new(@template).render(value: current_value) }
              )
            end
          end

          def time_field(attribute, options = {})
            rails_opts, form_field_opts = extract_options(options)
            html_native = form_field_opts.delete(:html_native) { false }
            field       = build_field(attribute, form_field_opts)

            if html_native
              html_opts = merge_html_options(rails_opts, field_theme(:form_input, error: field.error?), field.html_options)
              render_field(field, super(attribute, html_opts))
            else
              format        = rails_opts.delete(:format) { :h12 }
              step          = rails_opts.delete(:step) { 1 }
              current_value = object&.public_send(attribute)
              opts = Components::Combobox::Time.default_opts.deep_merge(
                input: { value: current_value }
              )
              render_field(
                field,
                render_combobox(
                  attribute,
                  field,
                  opts,
                  wrapper_data: {
                    input_format_type_value:    "time",
                    input_format_options_value: { format: format }.to_json
                  }
                ) { Components::Combobox::Time.new(@template).render(format: format, step: step, value: current_value) }
              )
            end
          end
        end
      end
    end
  end
end
