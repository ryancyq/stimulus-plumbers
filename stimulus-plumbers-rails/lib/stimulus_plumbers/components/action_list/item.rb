# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ActionList
      class Item < Plumber::Base
        def render(content = nil, **kwargs, &block)
          render_item(content, **kwargs, &block)
        end

        private

        def render_item(content, url: nil, external: false, active: false, **kwargs, &block)
          html_options = merge_html_options(
            { classes: theme.resolve(:action_list_item, active: active).fetch(:classes, "") },
            kwargs
          )

          template.content_tag(:li) do
            render_button(content, url: url, external: external, variant: :outline, **html_options, &block)
          end
        end

        def render_button(content, url: nil, external: false, **kwargs, &block)
          Components::Button.new(template).render(content, url: url, external: external, **kwargs, &block)
        end
      end
    end
  end
end
