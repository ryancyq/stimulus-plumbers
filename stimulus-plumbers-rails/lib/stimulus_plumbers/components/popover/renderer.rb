# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Popover
      class Builder
        attr_reader :activator_html, :content_html

        def initialize(template)
          @template = template
          @activator_html = "".html_safe
          @content_html   = "".html_safe
        end

        def activator(&block)
          @activator_html = @template.capture(&block)
        end

        def content(&block)
          @content_html = @template.capture(&block)
        end
      end

      class Renderer < Plumber::Base
        def popover(interactive: true, **kwargs, &block)
          self.html_options = {
            classes: theme.resolve(:popover).fetch(:classes, ""),
            **kwargs
          }

          builder = Builder.new(template)
          template.capture(builder, &block)

          template.content_tag(:div, **html_options) do
            wrapped_content = if interactive
                                template.content_tag(:template, builder.content_html)
                              else
                                builder.content_html
                              end
            template.safe_join([builder.activator_html, wrapped_content])
          end
        end
      end
    end
  end
end
