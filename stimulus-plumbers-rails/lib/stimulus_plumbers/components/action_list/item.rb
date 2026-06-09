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
          html_options = merge_html_options(
            theme.resolve(:action_list_item, active: active),
            kwargs
          )

          template.content_tag(:li) do
            if url.present?
              Components::Link.new(template).render(content, url: url, **html_options, &block)
            else
              Components::Button.new(template).render(content, variant: :ghost, **html_options, &block)
            end
          end
        end
      end
    end
  end
end
