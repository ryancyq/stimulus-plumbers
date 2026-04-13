# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Select
        def select(attribute, choices = nil, options = {}, html_options = {})
          custom_opts, rails_opts = extract_options(options)
          field = build_field(attribute, custom_opts)
          apply_aria_describedby!(field, html_options)
          apply_theme!(:form_select, html_options, error: field.error?)
          render_field(field, super(attribute, choices, rails_opts, html_options))
        end

        def collection_select(attribute, collection, value_method, text_method,
                              options = {}, html_options = {})
          custom_opts, rails_opts = extract_options(options)
          field = build_field(attribute, custom_opts)
          apply_aria_describedby!(field, html_options)
          apply_theme!(:form_select, html_options, error: field.error?)
          render_field(
            field,
            super(attribute, collection, value_method, text_method, rails_opts, html_options)
          )
        end
      end
    end
  end
end
