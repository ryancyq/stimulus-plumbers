# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Combobox
      module OptionGroup
        private

        def render_items(items, value: nil)
          @selected_value = value.to_s
          template.safe_join(items.map { |item| render_item(item) })
        end

        def render_item(item)
          case item
          when Hash
            item.key?(:options) ? render_group(item[:label], item[:options]) : render_option_hash(item)
          else
            render_option(item[0], item[1].to_s, item[2] || {})
          end
        end

        def render_option_hash(item)
          render_option(item[:label], item[:value].to_s, item.except(:label, :value))
        end

        def render_option(label, value, attrs = {})
          Option.new(template).render(
            label:       label,
            value:       value,
            selected:    @selected_value == value,
            disabled:    attrs[:disabled] || false,
            description: attrs[:description]
          )
        end

        def render_group(label, options)
          template.content_tag(:li, role: "group", aria: { label: label }) do
            template.safe_join(
              [
                template.content_tag(:span, label, aria: { hidden: "true" }),
                template.content_tag(:ul) do
                  template.safe_join(options.map { |opt| render_item(opt) })
                end
              ]
            )
          end
        end
      end
    end
  end
end
