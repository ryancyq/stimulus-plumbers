# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Submit
          def submit(value = nil, options = {})
            if value.is_a?(Hash)
              options = value
              value = nil
            end
            value ||= submit_default_value
            type    = options.delete(:type)    { :default }
            variant = options.delete(:variant) { :primary }

            Components::Button.new(@template).build(type: type, variant: variant) do |attrs|
              @template.tag.button(
                type: "submit",
                **merge_html_options(attrs, theme.resolve(:form_submit, type: type, variant: variant), options)
              ) { @template.content_tag(:span, value) }
            end
          end
        end
      end
    end
  end
end
