# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module DatePicker
      class Navigation < Plumber::Base
        attr_reader :stimulus_controller, :step

        def initialize(template, stimulus_controller:, step:, **kwargs)
          super(template)
          @stimulus_controller = stimulus_controller
          @step                = step
          self.html_options    = {
            classes: theme.resolve(:calendar_navigation).fetch(:classes, ""),
            aria:    { label: "DatePicker Navigation" },
            **kwargs
          }
        end

        def render
          template.content_tag(:nav, **html_options) do
            template.safe_join(navigators)
          end
        end

        private

        def navigators
          [
            Navigator.new(
              template,
              icon_options: { name: "arrow-left" },
              aria:         { label: ["previous", step].join(" ").titleize },
              data:         { "#{stimulus_controller}-target" => "previous" }
            ).render,
            Navigator.new(
              template,
              aria: { label: "Day" },
              data: { "#{stimulus_controller}-target" => "day" }
            ).render,
            Navigator.new(
              template,
              aria: { label: "Month" },
              data: { "#{stimulus_controller}-target" => "month" }
            ).render,
            Navigator.new(
              template,
              aria: { label: "Year" },
              data: { "#{stimulus_controller}-target" => "year" }
            ).render,
            Navigator.new(
              template,
              icon_options: { name: "arrow-right" },
              aria:         { label: ["next", step].join(" ").titleize },
              data:         { "#{stimulus_controller}-target" => "next" }
            ).render
          ]
        end
      end
    end
  end
end
