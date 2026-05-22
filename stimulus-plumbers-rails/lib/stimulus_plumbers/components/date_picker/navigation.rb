# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module DatePicker
      class Navigation < Plumber::Base
        def render(step:, stimulus_controller:, **kwargs)
          html_options = merge_html_options(
            { classes: theme.resolve(:calendar_navigation).fetch(:classes, ""), aria: { label: "DatePicker Navigation" } },
            kwargs
          )

          template.content_tag(:nav, **html_options) do
            template.safe_join(navigators(stimulus_controller, step))
          end
        end

        private

        def navigators(stimulus_controller, step)
          [
            navigator(stimulus_controller, target: "previous", icon: "arrow-left", label: ["previous", step].join(" ").titleize),
            navigator(stimulus_controller, target: "day",      label: "Day"),
            navigator(stimulus_controller, target: "month",    label: "Month"),
            navigator(stimulus_controller, target: "year",     label: "Year"),
            navigator(stimulus_controller, target: "next",     icon: "arrow-right", label: ["next", step].join(" ").titleize)
          ]
        end

        def navigator(stimulus_controller, target:, label:, icon: nil)
          opts = {
            aria: { label: label },
            data: { "#{stimulus_controller}-target" => target }
          }
          opts[:icon] = icon if icon
          Navigator.new(template).render(**opts)
        end
      end
    end
  end
end
