# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Renderer
        attr_reader :template, :theme, :field

        def initialize(template, theme, field)
          @template = template
          @theme    = theme
          @field    = field
        end

        def call(input_html)
          label_klass = theme.resolve(:form_label, required: field.required).fetch(:classes, "")
          label_klass = "#{label_klass} sr-only".strip if field.label_hidden?

          label_inner = field.label_text.dup.html_safe
          if field.required
            indicator_klass = theme.resolve(:form_required_mark).fetch(:classes, "")
            label_inner += template.content_tag(:span, "*", "aria-hidden": "true", class: indicator_klass)
          end

          label_html = template.content_tag(:label, label_inner, for: field.input_id, class: label_klass)

          hint_html = if field.details.present?
                        details_klass = theme.resolve(:form_details).fetch(:classes, "")
                        template.content_tag(:p, field.details, id: field.hint_id, class: details_klass)
                      else
                        "".html_safe
                      end

          errors_html = field.errors.map do |message|
            error_klass = theme.resolve(:form_error).fetch(:classes, "")
            template.content_tag(:p, message, id: field.error_id, class: error_klass, role: "alert")
          end.join.html_safe

          field_klass = theme.resolve(:form_group, layout: field.layout, error: field.error?).fetch(:classes, "")

          template.content_tag(:div, class: field_klass) do
            label_html + input_html.html_safe + hint_html + errors_html
          end
        end
      end
    end
  end
end
