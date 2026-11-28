# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Label
        class Floating < Plumber::Base
          def render(text:, for_id:, id:, floating:, required:, error:, &block)
            html_options = merge_html_options(theme.resolve(:form_field_floating_container, floating: floating))
            label_attrs  = merge_html_options(theme.resolve(:form_field_label, floating: floating, error: error))
            mark_attrs   = required && merge_html_options(
              { aria: { hidden: true } },
              theme.resolve(:form_field_required_mark)
            )
            template.content_tag(:div, **html_options) do
              template.safe_join(
                [
                  template.capture(&block),
                  render_label(text, mark_attrs, for: for_id, id: id, **label_attrs)
                ]
              )
            end
          end

          private

          def render_label(text, mark_attrs, **html_options)
            template.content_tag(:label, **html_options) do
              template.safe_join(
                [
                  text,
                  mark_attrs ? template.content_tag(:span, "*", **mark_attrs) : nil
                ]
              )
            end
          end
        end
      end
    end
  end
end
