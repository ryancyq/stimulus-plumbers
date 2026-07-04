# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class OrderedList < Plumber::Base
      def render(move_key: "Alt", editing: false, role: "list", **kwargs, &block)
        stimulus = {
          data: {
            controller:                   "reorderable",
            "reorderable-move-key-value": move_key,
            "reorderable-editing-value":  editing
          }
        }
        html_options = merge_html_options(theme.resolve(:ordered_list), kwargs, { role: role }, stimulus)
        template.content_tag(:ol, template.capture(self, &block), **html_options)
      end

      def item(content = nil, **kwargs, &block)
        OrderedList::Item.new(template).render(content, **kwargs, &block)
      end
    end
  end
end
