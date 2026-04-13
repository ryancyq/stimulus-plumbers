# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module DatePicker
      class Navigation < Plumber::Base
        def render(stimulus_controller:, step:, **kwargs)
          html_options = merge_html_options(
            { classes: theme.resolve(:calendar_navigation).fetch(:classes, ""), aria: { label: "DatePicker Navigation" } },
            **kwargs
          )

          template.content_tag(:nav, **html_options) do
            template.safe_join(navigators(stimulus_controller, step))
          end
        end

        private

        def navigators(stimulus_controller, step)
          [
            Navigator.new(template).render(
              icon_options: { name: "arrow-left" },
              aria:         { label: ["previous", step].join(" ").titleize },
              data:         { "#{stimulus_controller}-target" => "previous" }
            ),
            Navigator.new(template).render(
              aria: { label: "Day" },
              data: { "#{stimulus_controller}-target" => "day" }
            ),
            Navigator.new(template).render(
              aria: { label: "Month" },
              data: { "#{stimulus_controller}-target" => "month" }
            ),
            Navigator.new(template).render(
              aria: { label: "Year" },
              data: { "#{stimulus_controller}-target" => "year" }
            ),
            Navigator.new(template).render(
              icon_options: { name: "arrow-right" },
              aria:         { label: ["next", step].join(" ").titleize },
              data:         { "#{stimulus_controller}-target" => "next" }
            )
          ]
        end
      end
    end
  end
end
