# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module File
          def file_field(attribute, options = {})
            rails_opts, form_field_opts = extract_options(options)
            field     = build_field(attribute, form_field_opts)
            html_opts = merge_html_options(rails_opts, field_theme(:form_file, error: field.error?), field.html_options)
            render_field(field, super(attribute, html_opts))
          end
        end
      end
    end
  end
end
