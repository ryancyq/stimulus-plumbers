# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class List
      class Item < Plumber::Base
        def render(content = nil, **kwargs, &block)
          slots = List::Item::Slots.new(template)
          slots.with_title(content) if content
          slots.with_icon_trailing("external-link") if kwargs[:url].present? && kwargs[:target] == "_blank"
          yield slots if block_given?

          template.content_tag(:li) do
            build(**kwargs) do |attrs|
              render_link_or_button(**attrs) { render_item_slots(slots) }
            end
          end
        end

        def build(**kwargs, &block)
          html_options = merge_html_options(theme.resolve(:list_item), kwargs)
          template.capture(html_options, &block)
        end

        private

        def render_link_or_button(url: nil, target: nil, active: false, **html_options, &block)
          if url.present?
            aria = active ? { aria: { current: "page" } } : {}
            template.content_tag(:a, href: url, target: target, **merge_html_options(html_options, aria)) do
              template.capture(&block)
            end
          else
            aria = active ? { aria: { current: true } } : {}
            template.content_tag(:button, type: "button", **merge_html_options(html_options, aria)) do
              template.capture(&block)
            end
          end
        end

        def render_icon_slot(slots, name)
          slots.resolve(name) do |value|
            next value unless Components::Icon.icon_name?(value)

            Components::Icon.new(template).render(
              value,
              classes: theme.resolve(:list_item_icon).fetch(:classes, ""),
              aria:    { hidden: "true" }
            )
          end
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
            template.safe_join([title, description])
          end
        end

        def render_item_slots(slots)
          icon_leading  = render_icon_slot(slots, :icon_leading)
          icon_trailing = render_icon_slot(slots, :icon_trailing)
          content       = render_content_slot(slots)

          template.safe_join([icon_leading, content, icon_trailing])
        end
      end
    end
  end
end
