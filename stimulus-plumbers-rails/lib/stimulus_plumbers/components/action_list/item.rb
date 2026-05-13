# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ActionList
      class Item < Plumber::Base
        def render(content = nil, url: nil, external: false, active: false, **kwargs, &block)
          content      = template.capture(&block) if block_given?
          html_options = merge_html_options(
            { classes: theme.resolve(:action_list_item, active: active).fetch(:classes, "") },
            kwargs
          )

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
