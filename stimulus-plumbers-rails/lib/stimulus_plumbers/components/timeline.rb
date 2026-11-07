# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Timeline < Plumber::Base
      def render(orientation: :vertical, interactive: false, **kwargs, &block)
        @interactive = interactive
        @orientation = orientation
        content = template.capture(self, &block)
        timeline_stimulus_attrs = @interactive ? { data: { controller: "timeline" } } : {}
        ol_attrs = merge_html_options(theme.resolve(:timeline, orientation: orientation), kwargs, timeline_stimulus_attrs)
        list = template.content_tag(:ol, content, **ol_attrs)

        orientation.to_sym == :vertical ? render_vertical_container(list) : list
      end

      def event(datetime: nil, **kwargs, &block)
        ev = Timeline::Event.new(template)
        html = ev.render(
          datetime:    datetime,
          interactive: @interactive,
          orientation: @orientation,
          **kwargs,
          &block
        )
        @interactive ||= ev.interactive
        template.concat(html)
      end

      private

      def render_vertical_container(list)
        track_line = template.content_tag(:div, nil, **merge_html_options(theme.resolve(:timeline_track_line)))
        template.content_tag(:div, class: "relative") do
          template.safe_join([track_line, list])
        end
      end
    end
  end
end
