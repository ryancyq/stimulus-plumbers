# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Checklist
      class Item < Plumber::Base
        def render(content = nil, checked: nil, readonly: false, **html_options, &block)
          raise ArgumentError, "checked: is required" if checked.nil?

          slots = build_slots(content, &block)

          template.content_tag(:label, **merge_html_options(theme.resolve(:checklist_item), html_options)) do
            template.safe_join([render_input(checked, readonly), render_content_slot(slots)].compact)
          end
        end

        private

        def build_slots(content)
          slots = Checklist::Item::Slots.new(template)
          slots.with_title(content) if content
          yield slots if block_given?
          slots
        end

        def render_input(checked, readonly)
          template.tag.input(
            **merge_html_options(
              theme.resolve(:checklist_item_input),
              {
                type:     "checkbox",
                checked:  (checked ? true : nil),
                disabled: (readonly ? true : nil),
                data:     { checklist_target: "item" }
              }
            )
          )
        end

        def render_content_slot(slots)
          title       = render_title_slot(slots)
          description = render_description_slot(slots)
          return unless title || description

          template.content_tag(:span, **merge_html_options(theme.resolve(:checklist_item_content))) do
            template.safe_join([title, description])
          end
        end

        def render_title_slot(slots)
          slots.resolve(:title) do |v|
            template.content_tag(:span, v, **merge_html_options(theme.resolve(:checklist_item_title)))
          end
        end

        def render_description_slot(slots)
          slots.resolve(:description) do |v|
            template.content_tag(:span, v, **merge_html_options(theme.resolve(:checklist_item_description)))
          end
        end
      end
    end
  end
end
