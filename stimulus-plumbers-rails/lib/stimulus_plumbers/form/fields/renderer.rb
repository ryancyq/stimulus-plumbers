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
          field_klass = theme.resolve(:form_group, layout: field.layout, error: field.error?).fetch(:classes, "")

          template.content_tag(:div, class: field_klass) do
            label_html + input_html.html_safe + hint_html + errors_html
          end
        end

        private

        def label_html
          klass = theme.resolve(:form_label, required: field.required, hidden: field.label_hidden?).fetch(:classes, "")

          inner = field.label_text.dup.html_safe
          if field.required
            mark_klass = theme.resolve(:form_required_mark).fetch(:classes, "")
            inner += template.content_tag(:span, "*", "aria-hidden": "true", class: mark_klass)
          end

          template.content_tag(:label, inner, for: field.input_id, class: klass)
        end

        def hint_html
          return "".html_safe unless field.details.present?

          klass = theme.resolve(:form_details).fetch(:classes, "")
          template.content_tag(:p, field.details, id: field.hint_id, class: klass)
        end

        def errors_html
          return "".html_safe if field.errors.none?

          klass = theme.resolve(:form_error).fetch(:classes, "")
          field.errors.map.with_index(1) do |message, i|
            id = field.errors.one? ? field.error_id : "#{field.error_id}_#{i}"
            template.content_tag(:p, message, id: id, class: klass, role: "alert")
          end.join.html_safe
        end
      end
    end
  end
end
