# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class InputGroup < Plumber::Base
        def render(input_tag, trailing:, error: false, **wrapper_opts)
          klass = theme.resolve(:form_input_group, error: error).fetch(:classes, "")
          template.content_tag(:div, input_tag.html_safe + trailing, class: klass.presence, **wrapper_opts)
        end
      end
    end
  end
end
