# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module File
          def file_field(attribute, options = {})
            html_options = merge_html_options(options, field_theme(:form_file))
            super(attribute, html_options)
          end

          private

          def render_file_input(attribute, html_opts, opts, error, **kwargs)
            html_options = merge_html_options(opts, html_opts, kwargs, field_theme(:form_file, error: error))
            @template.file_field(@object_name, attribute, objectify_options(html_options))
          end
        end
      end
    end
  end
end
