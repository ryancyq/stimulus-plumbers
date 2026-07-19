# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Indicator < Plumber::Base
      def render(...)
        render_indicator(...)
      end

      private

      def render_indicator(variant: :primary, type: :dot, pulse: false, **kwargs, &block)
        dot = render_dot(variant: variant, type: type, kwargs: kwargs, block: block)
        return dot unless pulse

        template.content_tag(
          :span, template.safe_join([render_pulse_ring, dot]), **merge_html_options(theme.resolve(:indicator_wrapper))
        )
      end

      def render_dot(variant:, type:, kwargs:, block:)
        content      = block ? template.capture(&block) : nil
        html_options = merge_html_options(theme.resolve(:indicator, type: type, variant: variant), kwargs)
        template.content_tag(:span, content, **html_options)
      end

      def render_pulse_ring
        template.content_tag(:span, nil, **merge_html_options(theme.resolve(:indicator_pulse), { aria: { hidden: "true" } }))
      end
    end
  end
end
