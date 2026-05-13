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
          Group.new(template).render(layout: field.layout, error: field.error?) do
            (field_label + input_html.html_safe + field_hint + field_errors).html_safe
          end
        end

        private

        def field_label
          Label.new(template).render(
            text:     field.label_text,
            for_id:   field.input_id,
            required: field.required,
            hidden:   field.label_hidden?
          )
        end

        def field_hint
          return "".html_safe unless field.details.present?

          Hint.new(template).render(
            text: field.details,
            id:   field.hint_id
          )
        end

        def field_errors
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
