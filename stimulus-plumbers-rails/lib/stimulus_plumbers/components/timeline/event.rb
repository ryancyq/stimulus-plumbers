# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Timeline
      class Event < Plumber::Base
        attr_reader :interactive

        class << self
          def detail_id_for(event_id)
            [event_id, "detail"].compact.join("_")
          end
        end

        def render(datetime: nil, id: nil, interactive: false, orientation: :vertical, **kwargs, &block)
          @detail_id = self.class.detail_id_for(id || template.sp_dom_id)

          slots = Timeline::Event::Slots.new(template)
          yield slots if block_given?

          validate_slots!(slots, datetime: datetime)
          @orientation = orientation
          @interactive = interactive || slots.trigger?

          html_options = merge_html_options(theme.resolve(:timeline_item, orientation: orientation), kwargs)
          render_event(slots, datetime: datetime, html_options: html_options)
        end

        private

        def validate_slots!(slots, datetime:)
          raise ArgumentError, "e.title and e.trigger are mutually exclusive" if slots.title? && slots.trigger?
          raise ArgumentError, "e.detail requires e.trigger" if slots.detail? && !slots.trigger?
          raise ArgumentError, "e.time requires datetime:" if slots.time? && datetime.nil?
        end

        def render_event(slots, datetime:, html_options:)
          template.content_tag(:li, **html_options) do
            if @orientation.to_sym == :horizontal
              render_horizontal_event(slots, datetime: datetime)
            else
              render_vertical_event(slots, datetime: datetime)
            end
          end
        end

        def render_vertical_event(slots, datetime:)
          content_col = template.content_tag(:div, class: "flex-1 min-w-0") do
            template.safe_join(
              [
                render_time(slots, datetime: datetime),
                render_heading(slots),
                render_description(slots),
                render_detail(slots),
                render_actions(slots)
              ].compact
            )
          end
          template.safe_join([render_indicator(slots), content_col].compact)
        end

        def render_horizontal_event(slots, datetime:)
          template.safe_join(
            [
              render_horizontal_indicator_row(slots),
              render_horizontal_content(slots, datetime: datetime)
            ]
          )
        end

        def render_horizontal_indicator_row(slots)
          template.content_tag(:div, class: "flex items-center") do
            template.safe_join(
              [
                render_indicator(slots),
                template.content_tag(:div, nil, **merge_html_options(theme.resolve(:timeline_item_connector)))
              ].compact
            )
          end
        end

        def render_horizontal_content(slots, datetime:)
          template.content_tag(:div, **merge_html_options(theme.resolve(:timeline_item_content))) do
            template.safe_join(
              [
                render_time(slots, datetime: datetime),
                render_heading(slots),
                render_description(slots),
                render_detail(slots),
                render_actions(slots)
              ].compact
            )
          end
        end

        def render_indicator(slots)
          return unless slots.indicator?

          type         = slots.options_for(:indicator)[:type]
          icon_name    = slots.options_for(:indicator)[:icon]
          html_options = merge_html_options(
            theme.resolve(:timeline_item_indicator, type: type, orientation: @orientation),
            { aria: { hidden: "true" } }
          )
          template.content_tag(:div, **html_options) { render_indicator_content(type: type, icon_name: icon_name) }
        end

        def render_indicator_content(type:, icon_name:)
          if type == :icon && icon_name
            Components::Icon.new(template).render(
              icon_name,
              size:    :sm,
              classes: theme.resolve(:timeline_item_indicator_icon_slot).fetch(:classes, ""),
              aria:    { hidden: "true" }
            )
          else
            Components::Indicator.new(template).render(type: :dot, variant: :primary)
          end
        end

        def render_time(slots, datetime:)
          return unless datetime

          content = slots.resolve(:time)
          time_type = slots.options_for(:time)[:type] || :default
          time_target = @interactive ? { data: { "timeline-target": "time" } } : {}
          attrs = merge_html_options(theme.resolve(:timeline_item_time, type: time_type), { datetime: datetime }, time_target)
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
          trigger_attrs = if @interactive
                            merge_html_options(
                              theme.resolve(:timeline_item_trigger),
                              {
                                data: { "timeline-target": "trigger", action: "timeline#toggle" },
                                aria: { expanded: "false", controls: @detail_id }
                              }
                            )
                          else
                            merge_html_options(theme.resolve(:timeline_item_trigger))
                          end
          button = template.content_tag(:button, content, type: "button", **trigger_attrs)
          template.content_tag(:h3, button, **merge_html_options(theme.resolve(:timeline_item_heading)))
        end

        def render_description(slots)
          return unless slots.description?

          content = slots.resolve(:description)
          return unless content.present?

          template.content_tag(:p, content, **merge_html_options(theme.resolve(:timeline_item_description)))
        end

        def render_detail(slots)
          return unless slots.detail?

          content = slots.resolve(:detail)
          detail_attrs = if @interactive
                           merge_html_options(
                             theme.resolve(:timeline_item_detail),
                             { id: @detail_id, hidden: "", data: { "timeline-target": "detail" } }
                           )
                         else
                           merge_html_options(theme.resolve(:timeline_item_detail))
                         end
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
