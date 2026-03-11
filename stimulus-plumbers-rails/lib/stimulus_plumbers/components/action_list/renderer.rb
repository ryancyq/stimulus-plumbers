# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module ActionList
      class Renderer < Plumber::Base
        def list(**kwargs, &block)
          self.html_options = {
            classes: theme.resolve(:action_list).fetch(:classes, ""),
            **kwargs
          }
          template.content_tag(:div, template.capture(&block), **html_options)
        end

        def section(title: nil, **kwargs, &block)
          self.html_options = { **kwargs }
          template.content_tag(:div, **html_options) do
            template.safe_join(
              [
                (template.content_tag(:p, title) if title.present?),
                template.content_tag(:ul, template.capture(&block))
              ].compact
            )
          end
        end

        def item(content = nil, url: nil, external: false, active: false, **kwargs, &block)
          content = template.capture(&block) if block_given?
          self.html_options = {
            classes: theme.resolve(:action_list_item, active: active).fetch(:classes, ""),
            **kwargs
          }

          inner = if url
                    html_options[:target] = "_blank" if external
                    template.content_tag(:a, content, href: url, **html_options)
                  else
                    html_options[:type] ||= "button"
                    template.content_tag(:button, content, **html_options)
                  end

          template.content_tag(:li, inner)
        end
      end
    end
  end
end
