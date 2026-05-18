# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Label < Plumber::Base
        def render(text:, for_id:, required: false, hidden: false)
          inner = text.dup.html_safe
          if required
            mark_opts = merge_html_options(theme.resolve(:form_required_mark))
            inner += template.content_tag(:span, "*", "aria-hidden": "true", **mark_opts)
          end

          html_options = merge_html_options(theme.resolve(:form_label, required: required, hidden: hidden))
          template.content_tag(:label, inner, for: for_id, **html_options)
        end
      end
    end
  end
end
