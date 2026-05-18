# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Choice
          def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
            rails_opts, form_field_opts = extract_options(options)
            form_field_opts[:layout] ||= :inline
            field     = build_field(attribute, form_field_opts)
            html_opts = merge_html_options(rails_opts, field_theme(:form_checkbox, error: field.error?), field.html_opts)
            render_field(field, super(attribute, html_opts, checked_value, unchecked_value))
          end

          def radio_button(attribute, tag_value, options = {})
            rails_opts, form_field_opts = extract_options(options)
            form_field_opts[:layout] ||= :inline
            field     = build_field(attribute, form_field_opts, input_id: field_id(attribute, tag_value))
            html_opts = merge_html_options(rails_opts, field_theme(:form_radio, error: field.error?), field.html_opts)
            render_field(field, super(attribute, tag_value, html_opts))
          end
        end
      end
    end
  end
end
