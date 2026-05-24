# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Divider < Plumber::Base
      def render(label = nil, **kwargs)
        divider_opts = merge_html_options(
          { classes: theme.resolve(:divider).fetch(:classes, "") },
          kwargs
        )
        template.content_tag(:div, role: "separator", **divider_opts) do
          if label.blank?
            hr_classes = theme.resolve(:divider_separator).fetch(:classes, "")
            template.tag.hr(class: hr_classes)
          else
            render_with(label)
          end
        end
      end

      private

      def render_with(label)
        hr_classes = theme.resolve(:divider_separator).fetch(:classes, "")
        label_classes = theme.resolve(:divider_label).fetch(:classes, "")
        template.safe_join(
          [
            template.tag.hr(class: hr_classes),
            template.content_tag(:span, label, class: label_classes),
            template.tag.hr(class: hr_classes)
          ]
        )
      end
    end
  end
end
