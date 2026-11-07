# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Divider < Plumber::Base
      def render(label = nil, **kwargs)
        divider_attrs = merge_html_options(
          theme.resolve(:divider),
          kwargs
        )
        template.content_tag(:div, role: "separator", **divider_attrs) do
          if label.blank?
            template.tag.hr(**divider_separator_attrs)
          else
            render_with(label)
          end
        end
      end

      private

      def render_with(label)
        template.safe_join(
          [
            template.tag.hr(**divider_separator_attrs),
            template.content_tag(:span, label, **merge_html_options(theme.resolve(:divider_label))),
            template.tag.hr(**divider_separator_attrs)
          ]
        )
      end

      def divider_separator_attrs
        merge_html_options(theme.resolve(:divider_separator))
      end
    end
  end
end
