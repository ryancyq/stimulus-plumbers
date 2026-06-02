# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ActionList
      class Item < Plumber::Base
        def render(content = nil, **kwargs, &block)
          render_item(content, **kwargs, &block)
        end

        private

        def render_item(content, active: false, **kwargs, &block)
          html_options = merge_html_options(
            theme.resolve(:action_list_item, active: active),
            kwargs
          )

          template.content_tag(:li) do
            render_button(content, variant: :ghost, **html_options, &block)
          end
        end

        def render_button(content, ...)
          Components::Button.new(template).render(content, ...)
        end
      end
    end
  end
end
