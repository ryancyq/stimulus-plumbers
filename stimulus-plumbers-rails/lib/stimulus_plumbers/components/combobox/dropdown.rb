# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # Select-only combobox: a button showing the committed label.
      class Dropdown < Combobox
        MODE = "select_only"

        def render(**kwargs)
          editable = kwargs.compact.keys & Typeahead::OPTIONS
          raise ArgumentError, "#{editable.join(", ")} apply only to editable comboboxes" if editable.any?

          super
        end

        private

        def trigger_options(trigger)
          { **trigger, icon_trailing: trigger[:icon_trailing] || "chevron-down" }
        end

        def render_host(attrs)
          template.content_tag(:button, display_label, type: "button", **attrs)
        end
      end
    end
  end
end
