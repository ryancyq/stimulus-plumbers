# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module DatePicker
      class Navigator < Plumber::Base
        attr_reader :icon_options

        def initialize(template, icon_options: nil, **kwargs)
          super(template)
          @icon_options     = icon_options
          self.html_options = {
            classes: theme.resolve(:calendar_navigation_navigator).fetch(:classes, ""),
            **kwargs
          }
        end

        def render
          if icon_options.nil?
            template.content_tag(:button, nil, **html_options)
          else
            template.content_tag(:button, icon, **html_options)
          end
        end

        private

        def icon
          Icon::Renderer.new(template).icon(
            classes: theme.resolve(:calendar_navigation_navigator_icon).fetch(:classes, ""),
            **icon_options
          )
        end
      end
    end
  end
end
