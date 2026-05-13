# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class TimePicker < Plumber::Base
      CONTROLLER = "combobox-time"

      def render(items:, label:, target:, selected: nil)
        template.content_tag(
          :ul,
          role: "listbox",
          aria: { label: label },
          data: {
            "#{CONTROLLER}_target": target,
            action:                 "click->#{CONTROLLER}#select keydown->#{CONTROLLER}#navigate"
          }
        ) do
          template.safe_join(items.map { |text, value| render_item(text, value, selected) })
        end
      end

      private

      def render_item(text, value, selected)
        template.content_tag(
          :li,
          text,
          role: "option",
          aria: { selected: value.to_s == selected.to_s ? "true" : "false" },
          data: { value: value }
        )
      end
    end
  end
end
