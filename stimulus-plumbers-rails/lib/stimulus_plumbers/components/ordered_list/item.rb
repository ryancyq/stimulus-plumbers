# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class OrderedList
      class Item < Plumber::Base
        HANDLE_ACTION = "pointerdown->reorderable#onPointerDown pointermove->reorderable#onPointerMove " \
                        "pointerup->reorderable#onPointerUp"

        def render(content = nil, id:, handle: :item, url: nil, target: nil, active: false, **html_options, &block)
          validate_options!(id, url, html_options)

          slots = build_slots(content, &block)

          build(id: id, handle: handle) do |attrs|
            template.content_tag(:li, **attrs) do
              template.safe_join(
                [
                  render_icon_position(slots, :leading),
                  render_body(slots, url: url, target: target, active: active, **html_options),
                  render_icon_position(slots, :trailing)
                ]
              )
            end
          end
        end

        def build(id:, handle: :item, &block)
          @handle = handle
          html_options = merge_html_options(theme.resolve(:ordered_list_item), { id: id }, item_target_attrs)
          template.capture(html_options, &block)
        end

        private

        def validate_options!(id, url, html_options)
          raise ArgumentError, "id: is required so the item appears in reorderable:reordered's itemIds" if id.blank?
          return unless url.blank? && html_options.present?

          raise ArgumentError, "html_options are only applied to the <a> rendered when url: is set"
        end

        def build_slots(content, &block)
          slots = OrderedList::Item::Slots.new(template)
          slots.with_title(content) if content
          yield slots if block_given?
          slots
        end

        def item_target_attrs
          if @handle == :item
            { data: { "reorderable-target": "item handle", action: HANDLE_ACTION } }
          else
            { data: { "reorderable-target": "item" } }
          end
        end

        def render_body(slots, url:, target:, active:, **html_options)
          content = render_content_slot(slots)
          return content unless url.present?

          aria  = active ? { aria: { current: "page" } } : {}
          attrs = merge_html_options(html_options, { data: { "reorderable-target": "trigger" } }, aria)
          template.content_tag(:a, content, href: url, target: target, **attrs)
        end

        def render_icon_position(slots, position)
          slot_name   = position == :leading ? :icon_leading : :icon_trailing
          is_handle   = @handle == position
          custom_icon = render_icon_slot(slots, slot_name)
          return unless custom_icon || is_handle

          html_options = merge_html_options(theme.resolve(:ordered_list_item_handle), handle_target_attrs(is_handle))
          template.content_tag(:span, custom_icon || default_handle_icon, **html_options)
        end

        def handle_target_attrs(is_handle)
          return {} unless is_handle

          { data: { "reorderable-target": "handle", action: HANDLE_ACTION } }
        end

        def render_icon_slot(slots, name)
          slots.resolve(name) do |value|
            next value unless Components::Icon.icon_name?(value)

            Components::Icon.new(template).render(
              name:    value,
              size:    :sm,
              classes: theme.resolve(:ordered_list_item_handle).fetch(:classes, ""),
              aria:    { hidden: "true" }
            )
          end
        end

        def default_handle_icon
          Components::Icon.new(template).render(
            name:    "grip-vertical",
            size:    :sm,
            classes: theme.resolve(:ordered_list_item_handle).fetch(:classes, ""),
            aria:    { hidden: "true" }
          )
        end

        def render_content_slot(slots)
          title       = render_title_slot(slots)
          description = render_description_slot(slots)
          return unless title || description

          template.content_tag(:span, **merge_html_options(theme.resolve(:ordered_list_item_content))) do
            template.safe_join([title, description])
          end
        end

        def render_title_slot(slots)
          slots.resolve(:title) do |v|
            template.content_tag(:span, v, **merge_html_options(theme.resolve(:ordered_list_item_title)))
          end
        end

        def render_description_slot(slots)
          slots.resolve(:description) do |v|
            template.content_tag(:span, v, **merge_html_options(theme.resolve(:ordered_list_item_description)))
          end
        end
      end
    end
  end
end
