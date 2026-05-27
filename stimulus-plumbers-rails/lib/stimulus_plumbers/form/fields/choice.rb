# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Choice < Plumber::Base
        def render(label:, description: nil, **html_options, &block)
          merged = merge_html_options(theme.resolve(:form_collection_label), html_options)
          template.content_tag(:label, **merged) do
            template.safe_join([template.capture(&block), label_content(label, description)])
          end
        end

        private

        def label_content(label, description)
          return label unless description

          template.safe_join([
            label,
            template.content_tag(:span, description, **theme.resolve(:form_choice_item_description))
          ])
        end
      end
    end
  end
end
