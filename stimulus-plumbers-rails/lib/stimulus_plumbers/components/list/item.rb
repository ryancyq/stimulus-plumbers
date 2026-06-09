# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class List
      class Item < Plumber::Base
        def render(content = nil, **kwargs, &block)
          slots = List::Item::Slots.new
          slots.with_title(content) if content
          slots.with_icon_trailing("external-link") if kwargs[:url].present? && kwargs[:target] == "_blank"
          yield slots if block_given?

          template.content_tag(:li) do
            build(**kwargs) do |attrs|
              build_link_or_button(**attrs) { render_item_slots(slots) }
            end
          end
        end

        def build(**kwargs, &block)
          html_options = merge_html_options(theme.resolve(:list_item), kwargs)
          template.capture(html_options, &block)
        end

        private

        def render_icon_slot(slots, name)
          slots.resolve(name) { |v| render_icon(v, theme: :list_item_icon) }
        end

        def render_title_slot(slots)
          slots.resolve(:title) { |v| template.content_tag(:span, v, **merge_html_options(theme.resolve(:list_item_title))) }
        end

        def render_description_slot(slots)
          slots.resolve(:description) do |v|
            template.content_tag(:span, v, **merge_html_options(theme.resolve(:list_item_description)))
          end
        end

        def render_content_slot(slots)
          title       = render_title_slot(slots)
          description = render_description_slot(slots)
          return unless title || description

          template.content_tag(:span, **merge_html_options(theme.resolve(:list_item_content))) do
            template.safe_join([title, description].compact)
          end
        end

        def render_item_slots(slots)
          icon_leading  = render_icon_slot(slots, :icon_leading)
          icon_trailing = render_icon_slot(slots, :icon_trailing)
          content       = render_content_slot(slots)

          template.safe_join([icon_leading, content, icon_trailing].compact)
        end
      end
    end
  end
end
