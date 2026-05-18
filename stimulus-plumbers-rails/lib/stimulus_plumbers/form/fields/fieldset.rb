# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Fieldset < Plumber::Base
        def call(field, inputs_html, **fieldset_opts)
          Group.new(template).render(layout: field.layout, error: field.error?) do
            (fieldset_tag(field, inputs_html, **fieldset_opts) + field_hint(field) + field_errors(field)).html_safe
          end
        end

        private

        def fieldset_tag(field, inputs_html, **opts)
          template.content_tag(:fieldset, **opts) do
            (legend(field) + inputs_html.html_safe).html_safe
          end
        end

        def legend(field)
          inner = field.label_text.dup.html_safe
          if field.required
            mark_opts = merge_html_options(theme.resolve(:form_required_mark))
            inner += template.content_tag(:span, "*", "aria-hidden": "true", **mark_opts)
          end
          html_options = merge_html_options(theme.resolve(:form_label, required: field.required, hidden: field.label_hidden?))
          template.content_tag(:legend, inner, **html_options)
        end

        def field_hint(field)
          return "".html_safe unless field.details.present?

          Hint.new(template).render(text: field.details, id: field.hint_id)
        end

        def field_errors(field)
          return "".html_safe if field.errors.none?

          field.errors.map.with_index(1) do |message, i|
            id = field.errors.one? ? field.error_id : "#{field.error_id}_#{i}"
            Error.new(template).render(message: message, id: id)
          end.join.html_safe
        end
      end
    end
  end
end
