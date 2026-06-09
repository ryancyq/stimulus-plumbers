# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ActionList
      class Item < Plumber::Base
        def render(content = nil, icon_leading: nil, icon_trailing: nil, **kwargs, &block)
          icon_trailing ||= "external-link" if kwargs[:url].present? && kwargs[:target] == "_blank"
          template.content_tag(:li) do
            build(**kwargs) do |attrs|
              build_link_or_button(**attrs) do
                build_layout(icon_leading: icon_leading, icon_trailing: icon_trailing) do
                  build_item(content, &block)
                end
              end
            end
          end
        end

        def build(**kwargs, &block)
          html_options = merge_html_options(
            theme.resolve(:action_list_item),
            kwargs
          )
          template.capture(html_options, &block)
        end

        private

        def build_link_or_button(url: nil, **kwargs, &block)
          if url.present?
            build_link(url: url, **kwargs, &block)
          else
            build_button(**kwargs, &block)
          end
        end

        def build_link(url:, active: false, target: nil, **kwargs, &block)
          html_options = merge_html_options(
            kwargs,
            (active ? { aria: { current: "page" } } : {})
          )
          template.content_tag(:a, href: url, target: target, **html_options) do
            template.capture(&block)
          end
        end

        def build_button(active: false, **kwargs, &block)
          html_options = merge_html_options(
            kwargs,
            (active ? { aria: { current: true } } : {})
          )
          template.content_tag(:button, type: "button", **html_options) do
            template.capture(&block)
          end
        end

        def build_layout(icon_leading:, icon_trailing:, &block)
          template.safe_join(
            [
              render_icon(icon_leading, theme: :action_list_item_icon),
              template.capture(&block),
              render_icon(icon_trailing, theme: :action_list_item_icon)
            ]
          )
        end

        def build_item(content, &block)
          if block_given?
            template.content_tag(:span, template.capture(&block))
          elsif content
            template.content_tag(:span, content)
          end
        end
      end
    end
  end
end
