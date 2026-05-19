# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Hint < Plumber::Base
        def render(text:, id:)
          html_options = merge_html_options(theme.resolve(:form_details))
          template.content_tag(:p, text, id: id, **html_options)
        end
      end
    end
  end
end
