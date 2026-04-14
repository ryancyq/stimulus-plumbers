# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Select
        def select(attribute, choices = nil, options = {}, html_options = {})
          rails_opts, form_field_opts = extract_options(options)
          field     = build_field(attribute, form_field_opts)
          html_opts = merge_html_options(html_options, field_theme(:form_select, error: field.error?), field.html_opts)
          render_field(field, super(attribute, choices, rails_opts, html_opts))
        end

        def collection_select(attribute, collection, value_method, text_method,
                              options = {}, html_options = {})
          rails_opts, form_field_opts = extract_options(options)
          field     = build_field(attribute, form_field_opts)
          html_opts = merge_html_options(html_options, field_theme(:form_select, error: field.error?), field.html_opts)
          render_field(
            field,
            super(attribute, collection, value_method, text_method, rails_opts, html_opts)
          )
        end
      end
    end
  end
end
