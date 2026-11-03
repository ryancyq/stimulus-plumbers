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

          def render_option(label:, value:, id: nil, description: nil, disabled: false, selected: false)
            attrs = merge_html_options(
              theme.resolve(:combobox_option),
              option_attrs(label, value, id, description, disabled: disabled, selected: selected)
            )

            template.content_tag(:li, **attrs) do
              if description
                template.safe_join(
                  [
                    template.content_tag(:span, label, id: part_id(id, "label")),
                    render_description(description, id)
                  ]
                )
              else
                label
              end
            end
          end

          def render_description(description, id)
            template.content_tag(
              :span,
              description,
              **merge_html_options(theme.resolve(:combobox_option_description), { id: part_id(id, "description") })
            )
          end

          def option_attrs(label, value, id, description, disabled:, selected:)
            aria = { selected: selected ? "true" : "false", disabled: ("true" if disabled) }
            data = { value: value }

            # The description is not part of the name.
            if description
              data[:label] = label
              aria.merge!(labelledby: part_id(id, "label"), describedby: part_id(id, "description")) if id
            end

            { id: id, role: "option", aria: aria.compact, data: data }
          end

          def part_id(id, part)
            id && "#{id}_#{part}"
          end
        end
      end
    end
  end
end
