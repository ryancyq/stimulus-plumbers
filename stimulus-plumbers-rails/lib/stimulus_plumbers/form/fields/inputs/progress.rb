# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Progress
          private

          # A progressbar submits nothing and is never invalid — it reads its value from the model
          # attribute, and `floating:` is dropped so it can't leak onto the element as an attribute.
          def render_progress(attribute, html_opts, opts, _error, segments: nil, format: nil, **kwargs)
            html_options = merge_html_options(
              theme.resolve(:form_field_input_progress), opts, html_opts, kwargs.except(:floating)
            )
            value     = object.public_send(attribute)
            component = Components::ProgressBar.new(@template)
            if segments
              raise ArgumentError, "format: is not supported with segments:" unless format.nil?

              component.render_segmented(value: value, segments: segments, **html_options)
            else
              component.render(value: value, format: format, **html_options)
            end
          end
        end
      end
    end
  end
end
