# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module TextArea
          def text_area(attribute, floating: nil, **options)
            html_options = merge_html_options(theme.resolve(:form_field_input_textarea, floating: floating), options)
            super(attribute, html_options)
          end

          private

          def render_text_area_input(attribute, html_opts, opts, error, floating: nil, **kwargs)
            html_options = merge_html_options(
              theme.resolve(:form_field_input_textarea, floating: floating, error: error),
              opts,
              html_opts,
              kwargs
            )
            @template.text_area(@object_name, attribute, objectify_options(html_options))
          end
        end
      end
    end
  end
end
