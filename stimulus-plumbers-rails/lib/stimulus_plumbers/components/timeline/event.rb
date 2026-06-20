# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Timeline
      class Event < Plumber::Base
        def self.detail_id_for(event_id)
          [event_id, "detail"].compact.join("_")
        end

        def render(datetime: nil, id: nil, **kwargs, &block)
          @detail_id = self.class.detail_id_for(id || template.sp_dom_id)

          slots = Timeline::Event::Slots.new
          yield slots if block_given?

          raise ArgumentError, "e.title and e.trigger are mutually exclusive" if slots.title? && slots.trigger?
          raise ArgumentError, "e.detail requires e.trigger" if slots.detail? && !slots.trigger?
          raise ArgumentError, "e.time requires datetime:" if slots.time? && datetime.nil?

          html_options = merge_html_options(theme.resolve(:timeline_item), kwargs)
          template.content_tag(:li, **html_options) do
            template.safe_join([
              render_indicator(slots),
              render_time(slots, datetime: datetime),
              render_heading(slots),
              render_description(slots),
              render_detail(slots),
              render_actions(slots)
            ].compact)
          end
        end

        private

        def render_indicator(slots)
          return unless slots.indicator?

          type = slots.options_for(:indicator)[:type]
          icon_name = slots.options_for(:indicator)[:icon]
          html_options = merge_html_options(theme.resolve(:timeline_item_indicator, type: type), { aria: { hidden: "true" } })
          if type == :icon && icon_name
            template.content_tag(:div, **html_options) do
              Components::Icon.new(template).render(name: icon_name, aria: { hidden: "true" })
            end
          else
            template.content_tag(:div, nil, html_options)
          end
        end

        def render_time(slots, datetime:)
          return unless datetime

          content = slots.resolve(:time)
          attrs = merge_html_options(theme.resolve(:timeline_item_time), { datetime: datetime })
          template.content_tag(:time, content, **attrs)
        end

        def render_heading(slots)
          if slots.trigger?
            render_trigger_heading(slots)
          elsif slots.title?
            content = slots.resolve(:title)
            template.content_tag(:h3, content, **merge_html_options(theme.resolve(:timeline_item_title)))
          end
        end

        def render_trigger_heading(slots)
          content = slots.resolve(:trigger)
          trigger_attrs = merge_html_options(
            theme.resolve(:timeline_item_trigger),
            {
              data: { "timeline-target": "trigger", action: "timeline#toggle" },
              aria: { expanded: "false", controls: @detail_id }
            }
          )
          button = template.content_tag(:button, content, type: "button", **trigger_attrs)
          template.content_tag(:h3, button, **merge_html_options(theme.resolve(:timeline_item_heading)))
        end

        def render_description(slots)
          content = slots.resolve(:description)
          return unless content.present?

          template.content_tag(:p, content, **merge_html_options(theme.resolve(:timeline_item_description)))
        end

        def render_detail(slots)
          return unless slots.detail?

          content = slots.resolve(:detail)
          detail_attrs = merge_html_options(
            theme.resolve(:timeline_item_detail),
            { id: @detail_id, hidden: "", data: { "timeline-target": "detail" } }
          )
          template.content_tag(:div, content, **detail_attrs)
        end

        def render_actions(slots)
          return unless slots.actions?

          content = slots.resolve(:actions)
          return unless content.present?

          template.content_tag(:div, content, **merge_html_options(theme.resolve(:timeline_item_actions)))
        end
      end
    end
  end
end
