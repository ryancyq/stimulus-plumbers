# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Options
        class OptionGroup < Plumber::Base
          def render(label:, options:, value: nil)
            attrs = merge_html_options(
              { classes: theme.resolve(:combobox_option_group).fetch(:classes, "") },
              { role: "group", aria: { label: label } }
            )

            template.content_tag(:li, **attrs) do
              template.safe_join(
                [
                  template.content_tag(:span, label, aria: { hidden: "true" }),
                  template.content_tag(:ul) do
                    Options.new(template).render(options, value: value)
                  end
                ]
              )
            end
          end
        end
      end
    end
  end
end
