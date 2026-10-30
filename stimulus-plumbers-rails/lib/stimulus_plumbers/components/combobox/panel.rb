# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # The manual popover panel; the block renders its content.
      class Panel < Plumber::Base
        def render(...)
          render_panel(...)
        end

        private

        def render_panel(id:, theme_key:, &content)
          Popover.new(template).build(panel_id: id, mode: :manual) do |popover|
            popover.build_panel(
              classes:        theme.resolve(theme_key).fetch(:classes, ""),
              popover_target: false,
              data:           { "#{Combobox::STIMULUS_CONTROLLER}-target" => "panel" }
            ) do |panel_attrs|
              template.content_tag(:div, content.call, **panel_attrs)
            end
          end
        end
      end
    end
  end
end
