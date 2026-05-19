# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Popover < Plumber::Base
        def render(stimulus_controller:, id:, tag: :div, role: nil, label: nil, content: nil, data: {}, &block)
          stimulus_data = { "#{stimulus_controller}_target": "popover" }

          attrs = { id: id, hidden: "", data: merge_data_options(stimulus_data, data) }
          attrs[:role] = role if role
          attrs[:aria] = { label: label } if label

          html_content = block_given? ? template.capture(id, &block) : content
          template.content_tag(tag, **attrs) { html_content }
        end
      end
    end
  end
end
