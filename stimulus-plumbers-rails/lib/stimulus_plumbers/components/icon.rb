# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Icon < Plumber::Base
      def render(name:, **kwargs)
        html_options = merge_html_options(
          { classes: theme.resolve(:icon).fetch(:classes, "") },
          kwargs
        )

        icon_data = Themes::Schema::Icon.resolve(theme.icons[name])
        if icon_data
          svg_icon(icon_data, html_options)
        else
          template.tag.span(**html_options)
        end
      end

      private

      def svg_icon(icon_data, html_options)
        template.content_tag(
          :svg,
          xmlns:          "http://www.w3.org/2000/svg",
          fill:           icon_data[:fill],
          viewBox:        icon_data[:view_box],
          width:          icon_data[:width],
          height:         icon_data[:height],
          stroke:         icon_data[:stroke],
          "stroke-width": icon_data[:stroke_width],
          **html_options
        ) do
          template.tag.path(
            "stroke-linecap":  icon_data[:stroke_linecap],
            "stroke-linejoin": icon_data[:stroke_linejoin],
            d:                 icon_data[:d]
          )
        end
      end
    end
  end
end
