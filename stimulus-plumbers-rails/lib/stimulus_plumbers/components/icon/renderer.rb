# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Icon
      class Renderer < Plumber::Base
        ICONS = {
          "arrow-left"  => "M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18",
          "arrow-right" => "M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3",
          "arrow-up"    => "M4.5 10.5 12 3m0 0 7.5 7.5M12 3v18",
          "arrow-down"  => "M19.5 13.5 12 21m0 0-7.5-7.5M12 21V3"
        }.freeze

        def icon(name:, **kwargs)
          self.html_options = { 
            classes: theme.resolve(:icon).fetch(:classes, ""),
            **kwargs
          }

          if ICONS[name]
            svg_icon(ICONS[name])
          else
            template.content_tag(:span, nil, **html_options)
          end
        end

        private

        def svg_icon(path)
          template.content_tag(
            :svg,
            xmlns:          "http://www.w3.org/2000/svg",
            fill:           "none",
            viewBox:        "0 0 24 24",
            "stroke-width": "1.5",
            stroke:         "currentColor",
            **html_options
          ) do
            template.tag.path(
              "stroke-linecap":  "round",
              "stroke-linejoin": "round",
              d:                 path
            )
          end
        end
      end
    end
  end
end
