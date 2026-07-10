# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Icon < Plumber::Base
      def self.icon_name?(value)
        value.is_a?(Symbol) || (value.is_a?(String) && !value.html_safe?)
      end

      def render(name:, size: :lg, **kwargs)
        html_options = merge_html_options(
          theme.resolve(:icon, size: size),
          kwargs
        )

        icon_data = Themes::Schema::Icon.resolve(theme.icons[name.to_s])
        if icon_data
          svg_icon(icon_data, html_options)
        else
          template.tag.span(**html_options)
        end
      end

      private

      def svg_icon(icon_data, html_options)
        template.content_tag(:svg, nil, icon_data.except(:elements).merge(html_options)) do
          template.safe_join(
            icon_data[:elements].map do |element|
              template.content_tag(element[:tag], nil, element.except(:tag))
            end
          )
        end
      end
    end
  end
end
