# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module File
          def file_field(attribute, floating: nil, **options)
            html_options = merge_html_options(theme.resolve(:form_field_input_file, floating: floating), options)
            super(attribute, html_options)
          end

          private

          def render_file_input(attribute, html_opts, opts, error, floating: nil, **kwargs)
            html_options = merge_html_options(
              theme.resolve(:form_field_input_file, floating: floating, error: error),
              opts,
              html_opts,
              kwargs
            )
            @template.file_field(@object_name, attribute, objectify_options(html_options))
          end
        end
      end
    end
  end
end
