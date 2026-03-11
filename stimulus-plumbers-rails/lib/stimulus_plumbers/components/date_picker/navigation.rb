# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module DatePicker
      class Navigation < Plumber::Base
        def navigation(stimulus_controller:, step:, **kwargs)
          self.html_options = {
            classes: theme.resolve(:calendar_navigation).fetch(:classes, ""),
            aria: { label: "DatePicker Navigation" },
            **kwargs
          }

          template.content_tag(:nav, **html_options) do
            template.safe_join([
              Navigator.new(template).navigator(
                icon_options: { name: "arrow-left" },
                aria: { label: ["previous", step].join(" ").titleize },
                data: { "#{stimulus_controller}-target" => "previous"}
              ),
              Navigator.new(template).navigator(
                data: { "#{stimulus_controller}-target" => "day"}
              ),
              Navigator.new(template).navigator(
                data: { "#{stimulus_controller}-target" => "month"}
              ),
              Navigator.new(template).navigator(
                data: { "#{stimulus_controller}-target" => "year"}
              ),
              Navigator.new(template).navigator(
                icon_options: { name: "arrow-right" },
                aria: { label: ["next", step].join(" ").titleize },
                data: { "#{stimulus_controller}-target" => "next"}
              )
            ])
          end
        end
      end
    end
  end
end
