# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class InputGroup < Plumber::Base
        def render(input_html, trailing:, error: false, **wrapper_opts)
          html_options = merge_html_options(theme.resolve(:form_input_group, error: error), wrapper_opts)
          template.content_tag(:div, input_html.html_safe + trailing, **html_options)
        end
      end
    end
  end
end
