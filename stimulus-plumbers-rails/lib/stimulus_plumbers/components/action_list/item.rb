# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ActionList
      class Item < Plumber::Base
        def render(content = nil, **kwargs, &block)
          render_item(content, **kwargs, &block)
        end

        private

        def render_item(content, active: false, url: nil, **kwargs, &block)
          template.content_tag(:li) do
            if url.present?
              render_link(content, active: active, url: url, **kwargs, &block)
            else
              render_button(content, active: active, **kwargs, &block)
            end
          end
        end

        def render_link(content, active:, url:, **kwargs, &block)
          html_options = merge_html_options(
            theme.resolve(:action_list_item),
            (active ? { aria: { current: "page" } } : {}),
            kwargs
          )
          Components::Link.new(template).render(content, url: url, **html_options, &block)
        end

        def render_button(content, active:, **kwargs, &block)
          html_options = merge_html_options(
            theme.resolve(:action_list_item),
            (active ? { aria: { current: true } } : {}),
            kwargs
          )
          Components::Button.new(template).render(content, type: :ghost, **html_options, &block)
        end
      end
    end
  end
end
