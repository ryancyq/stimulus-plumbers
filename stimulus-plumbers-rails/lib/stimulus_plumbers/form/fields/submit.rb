# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Submit
        def submit(value = nil, options = {})
          if value.is_a?(Hash)
            options = value
            value = nil
          end
          value   ||= submit_default_value
          variant   = options.delete(:variant) { :default }
          @template.tag.input(
            type:  "submit",
            value: value,
            **merge_html_options(field_theme(:form_submit, variant: variant), options)
          )
        end
      end
    end
  end
end
