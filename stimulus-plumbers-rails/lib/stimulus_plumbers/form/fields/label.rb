# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Label < Plumber::Base
        def render(text:, for_id: nil, id: nil, required: false, hidden: false, tag: :label)
          mark_options = required && merge_html_options(
            { aria: { hidden: true } },
            theme.resolve(:form_field_required_mark)
          )
          html_options = merge_html_options(theme.resolve(:form_field_label, required: required, hidden: hidden))
          render_label(text, mark_options, tag, for: for_id, id: id, **html_options)
        end

        private

        def render_label(text, mark_options, tag, **html_options)
          template.content_tag(tag, **html_options) do
            template.safe_join(
              [
                text,
                mark_options ? template.content_tag(:span, "*", **mark_options) : nil
              ]
            )
          end
        end
      end
    end
  end
end
