# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ActionList
      class Item < Plumber::Base
        def render(content = nil, **kwargs, &block)
          render_item(content, **kwargs, &block)
        end

        private

        def render_item(content, url: nil, external: false, active: false, **html_options, &block)
          html_options = merge_html_options(
            { classes: theme.resolve(:action_list_item, active: active).fetch(:classes, "") },
            html_options
          )

          template.content_tag(:li) do
            render_button(content, url: url, external: external, **html_options, &block)
          end
        end

        def render_button(content, url: nil, external: false, **html_options, &block)
          Components::Button.new(template).render(content, url: url, external: external, **html_options, &block)
        end
      end
    end
  end
end
