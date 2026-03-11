# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Button
      class Renderer < Plumber::Base
        def button(content = nil, url: nil, external: false, variant: :primary, size: :md, **kwargs, &block)
          content = template.capture(&block) if block_given?
          self.html_options = {
            classes: theme.resolve(:button, variant: variant, size: size).fetch(:classes, ""),
            **kwargs
          }

          if url
            html_options[:target] = "_blank" if external
            template.content_tag(:a, content, href: url, **html_options)
          else
            html_options[:type] ||= "button"
            template.content_tag(:button, content, **html_options)
          end
        end

        def group(alignment: :left, direction: :row, **kwargs, &block)
          classes = theme.resolve(:button_group, alignment: alignment, direction: direction).fetch(:classes, "")
          self.html_options = {
            classes: classes,
            **kwargs
          }
          template.content_tag(:div, template.capture(&block), **html_options)
        end
      end
    end
  end
end
