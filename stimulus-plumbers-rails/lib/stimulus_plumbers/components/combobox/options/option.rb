# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Options
        class Option < Plumber::Base
          def render(...)
            render_option(...)
          end

          private

          def render_option(label:, value:, description: nil, disabled: false, selected: false)
            aria = { selected: selected ? "true" : "false" }
            aria[:disabled] = "true" if disabled

            attrs = merge_html_options(
              { classes: theme.resolve(:combobox_option, selected: selected, disabled: disabled).fetch(:classes, "") },
              { role: "option", aria: aria, data: { value: value } }
            )

            template.content_tag(:li, **attrs) do
              if description
                template.safe_join(
                  [
                    template.content_tag(:span, label),
                    template.content_tag(:span, description)
                  ]
                )
              else
                label
              end
            end
          end
        end
      end
    end
  end
end
