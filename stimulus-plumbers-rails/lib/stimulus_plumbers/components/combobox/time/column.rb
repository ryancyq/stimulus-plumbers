# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Time
        class Column < Plumber::Base
          def render(stimulus_controller:, target:, label:, items:, selected: nil)
            template.content_tag(
              :ul,
              role: "listbox",
              aria: { label: label },
              data: {
                "#{stimulus_controller}_target": target,
                action:                          "click->#{stimulus_controller}#select keydown->#{stimulus_controller}#navigate"
              }
            ) do
              template.safe_join(
                items.map do |text, value|
                  Option.new(template).render(
                    label:    text,
                    value:    value,
                    selected: value.to_s == selected.to_s
                  )
                end
              )
            end
          end
        end
      end
    end
  end
end
