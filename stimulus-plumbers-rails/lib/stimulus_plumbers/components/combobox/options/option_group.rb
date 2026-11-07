# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Options
        # A listbox may only own options and groups.
        class OptionGroup < Plumber::Base
          def render(...)
            render_option_group(...)
          end

          private

          def render_option_group(label:, id: nil, &block)
            template.content_tag(:li, **merge_html_options(theme.resolve(:combobox_option_group), { role: "none" })) do
              template.content_tag(:ul, role: "group", aria: { labelledby: id }.compact) do
                template.safe_join(
                  [
                    template.content_tag(
                      :li,
                      label,
                      **merge_html_options(theme.resolve(:combobox_option_group_label), { id: id, role: "none" })
                    ),
                    template.capture(&block)
                  ]
                )
              end
            end
          end
        end
      end
    end
  end
end
