# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class OrderedList < Plumber::Base
      def render(move_key: "Alt", editing: false, orientation: nil, role: "list", **kwargs, &block)
        stimulus = {
          data: {
            controller:                      "reorderable",
            "reorderable-move-key-value":    move_key,
            "reorderable-editing-value":     editing,
            "reorderable-orientation-value": orientation
          }.compact
        }
        html_options = merge_html_options(theme.resolve(:ordered_list), kwargs, stimulus)
        template.content_tag(:ol, template.capture(self, &block), **html_options, role: role)
      end

      def item(content = nil, **kwargs, &block)
        OrderedList::Item.new(template).render(content, **kwargs, &block)
      end
    end
  end
end
