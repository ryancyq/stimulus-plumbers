# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class InputGroup < Plumber::Base
        def render(leading: nil, trailing: nil, error: false, **wrapper_opts)
          html_options = merge_html_options(
            theme.resolve(:form_input_group, error: error),
            wrapper_opts
          )
          template.content_tag(:div, **html_options) do
            template.safe_join(
              [
                leading.respond_to?(:call) ? leading.call : leading,
                yield,
                trailing.respond_to?(:call) ? trailing.call : trailing
              ]
            )
          end
        end
      end
    end
  end
end
