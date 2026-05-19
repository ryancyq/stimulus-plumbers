# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Error < Plumber::Base
        def render(message:, id:)
          html_options = merge_html_options(theme.resolve(:form_error))
          template.content_tag(:p, message, id: id, role: "alert", **html_options)
        end
      end
    end
  end
end
