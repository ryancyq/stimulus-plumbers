# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Text
        FIELD_TYPES = %i[
          text_field email_field url_field telephone_field search_field
          number_field color_field date_field datetime_local_field
          time_field month_field week_field range_field
          password_field
        ].freeze

        FIELD_TYPES.each do |method_name|
          define_method(method_name) do |attribute, options = {}|
            rails_opts, form_field_opts = extract_options(options)
            field = build_field(attribute, form_field_opts)
            html_opts = merge_html_options(rails_opts, field_theme(:form_input, error: field.error?), field.html_opts)
            render_field(field, super(attribute, html_opts))
          end
        end
      end
    end
  end
end
