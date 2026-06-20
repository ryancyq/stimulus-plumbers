# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Timeline < Plumber::Base
      def render(orientation: :vertical, interactive: false, **kwargs, &block)
        stimulus = interactive ? { data: { controller: "timeline" } } : {}
        html_options = merge_html_options(theme.resolve(:timeline, orientation: orientation), kwargs, stimulus)
        template.content_tag(:ol, template.capture(self, &block), **html_options)
      end

      def event(datetime: nil, **kwargs, &block)
        Timeline::Event.new(template).render(datetime: datetime, **kwargs, &block)
      end
    end
  end
end
