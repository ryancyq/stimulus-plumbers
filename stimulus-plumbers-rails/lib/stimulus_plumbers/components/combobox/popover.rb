# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Popover < Plumber::Base
        def render(stimulus_controller:, id:, **kwargs, &block)
          merged = merge_html_options(
            { classes: theme.resolve(:combobox_popover).fetch(:classes, "") },
            { data:    { "#{stimulus_controller}_target": "popover" } },
            kwargs
          )
          Components::Popover::Panel.new(template).render(panel_id: id, **merged, &block)
        end
      end
    end
  end
end
