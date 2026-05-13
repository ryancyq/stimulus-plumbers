# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Label < Plumber::Base
        def render(text:, for_id:, required: false, hidden: false)
          klass = theme.resolve(:form_label, required: required, hidden: hidden).fetch(:classes, "")

          inner = text.dup.html_safe
          if required
            mark_klass = theme.resolve(:form_required_mark).fetch(:classes, "")
            inner += template.content_tag(:span, "*", "aria-hidden": "true", class: mark_klass.presence)
          end

          template.content_tag(:label, inner, for: for_id, class: klass.presence)
        end
      end
    end
  end
end
