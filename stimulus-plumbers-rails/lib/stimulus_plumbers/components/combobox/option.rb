# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Combobox
      class Option < Plumber::Base
        def render(label:, value:, description: nil, disabled: false, selected: false)
          aria = { selected: selected ? "true" : "false" }
          aria[:disabled] = "true" if disabled

          template.content_tag(:li, role: "option", aria: aria, data: { value: value }) do
            if description
              template.safe_join(
                [
                  template.content_tag(:span, label),
                  template.content_tag(:span, description)
                ]
              )
            else
              label
            end
          end
        end
      end
    end
  end
end
