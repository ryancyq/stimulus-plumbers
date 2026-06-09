# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Label
        class Floating < Plumber::Base
          def render(text:, for_id:, id:, type:, required:, error:, &block)
            html_options  = merge_html_options(theme.resolve(:form_floating_group, type: type))
            label_options = merge_html_options(theme.resolve(:form_floating_label, type: type, error: error))
            mark_options  = required && merge_html_options(
              { aria: { hidden: true } },
              theme.resolve(:form_required_mark)
            )
            template.content_tag(:div, **html_options) do
              template.safe_join(
                [
                  template.capture(&block),
                  render_label(text, mark_options, for: for_id, id: id, **label_options)
                ]
              )
            end
          end

          private

          def render_label(text, mark_options, **html_options)
            template.content_tag(:label, **html_options) do
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
end
