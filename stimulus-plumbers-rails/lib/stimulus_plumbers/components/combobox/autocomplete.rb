# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Combobox
      # Renders a listbox popover body for autocomplete. Initial options rendered server-side;
      # the Stimulus controller populates dynamically as the user types.
      class Autocomplete < Plumber::Base
        include OptionGroup

        def self.default_opts
          {
            popover: { role: "listbox", tag: :ul },
            trigger: { aria_autocomplete: "list", readonly: false }
          }
        end

        def render(options: [], value: nil, **_kwargs)
          render_items(options, value: value)
        end
      end
    end
  end
end
