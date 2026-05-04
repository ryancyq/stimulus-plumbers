# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Combobox
      # Renders a static listbox popover body. Supports flat options, descriptions, and groups.
      class Dropdown < Plumber::Base
        include OptionGroup

        def self.default_opts = { popover: { role: "listbox", tag: :ul } }

        def render(options: [], value: nil, **_kwargs)
          render_items(options, value: value)
        end
      end
    end
  end
end
