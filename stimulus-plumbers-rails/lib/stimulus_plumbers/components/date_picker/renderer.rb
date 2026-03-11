# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module DatePicker
      class Renderer < Plumber::Base
        STIMULUS_CONTROLLER = "datepicker"

        def datepicker(stimulus_controller: nil, **kwargs)
          self.html_options = {
            classes: theme.resolve(:datepicker).fetch(:classes, ""),
            data: {
              controller: STIMULUS_CONTROLLER,
            },
            **kwargs
          }

          template.content_tag(:div, **html_options) do
            template.safe_join([
              navigation(stimulus_controller: STIMULUS_CONTROLLER, step: "month"),
              calendar_month(data: { action: "#{STIMULUS_CONTROLLER}:navigated->#{Calendar::Renderer::STIMULUS_CONTROLLER}#draw"})
            ])
          end
        end

        def navigation(**kwargs)
          Navigation.new(template).navigation(**kwargs)
        end

        def calendar_month(**kwargs)
          Calendar::Renderer.new(template).month(**kwargs)
        end
      end
    end
  end
end
