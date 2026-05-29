# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module TextArea
          def text_area(attribute, options = {})
            html_options = merge_html_options(options, field_theme(:form_textarea))
            super(attribute, html_options)
          end

          private

          def render_text_area_input(attribute, html_opts, opts, error, **kwargs)
            html_options = merge_html_options(opts, html_opts, kwargs, field_theme(:form_textarea, error: error))
            @template.text_area(@object_name, attribute, objectify_options(html_options))
          end
        end
      end
    end
  end
end
