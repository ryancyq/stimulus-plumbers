# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Avatar
      class Renderer < Plumber::Base
        def avatar(name: nil, initials: nil, url: nil, color: nil, size: :md, **kwargs, &block)
          color_css = resolve_color(color, name, initials) unless url || block_given?

          self.html_options = {
            classes:      [theme.resolve(:avatar, size: size).fetch(:classes, ""), color_css],
            "aria-label": name,
            role:         "img",
            **kwargs
          }

          template.content_tag(:span, inner(name, initials, url, &block), **html_options)
        end

        private

        def inner(name, initials, url, &block)
          if block_given?
            template.capture(&block)
          elsif url
            template.tag.img(src: url, alt: name.present? ? "#{name}'s avatar" : "", onerror: "this.src=''")
          elsif initials
            initials_svg(initials)
          else
            fallback_svg
          end
        end

        def resolve_color(color, name, initials)
          if color
            theme.avatar_colors.fetch(color, nil)
          elsif (seed = name || initials)
            theme.avatar_color_range[seed.bytes.reduce(:^) % theme.avatar_color_range.length]
          else
            theme.avatar_color_range.first
          end
        end

        def initials_svg(initials)
          template.content_tag(:svg, viewBox: "0 0 40 40") do
            template.content_tag(
              :text,
              initials.upcase,
              x:             "50%",
              y:             "50%",
              dy:            "0.35em",
              fill:          "currentColor",
              "font-size":   "20",
              "text-anchor": "middle"
            )
          end
        end

        def fallback_svg
          template.content_tag(:svg, viewBox: "0 0 40 40") do
            template.tag.path(
              fill: "currentColor",
              d:    "M8.28 27.5A14.95 14.95 0 0120 21.8c4.76 0 8.97 2.24 11.72 5.7a14.02 " \
                    "14.02 0 01-8.25 5.91 14.82 14.82 0 01-6.94 0 14.02 14.02 0 01-8.25-5.9z" \
                    "M13.99 12.78a6.02 6.02 0 1112.03 0 6.02 6.02 0 01-12.03 0z"
            )
          end
        end
      end
    end
  end
end
