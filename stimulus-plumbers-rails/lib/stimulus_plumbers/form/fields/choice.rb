# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Choice
        def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
          custom_opts, rails_opts = extract_options(options)
          custom_opts[:layout]   ||= :inline
          custom_opts[:input_id] ||= "#{object_name}_#{attribute}"
          rails_opts[:id]        ||= custom_opts[:input_id]
          field = build_field(attribute, custom_opts)
          apply_theme!(:form_checkbox, rails_opts, error: field.error?)
          render_field(field, super(attribute, rails_opts, checked_value, unchecked_value))
        end

        def radio_button(attribute, tag_value, options = {})
          custom_opts, rails_opts = extract_options(options)
          custom_opts[:layout]   ||= :inline
          custom_opts[:input_id] ||= "#{object_name}_#{attribute}_#{tag_value}"
          rails_opts[:id]        ||= custom_opts[:input_id]
          field = build_field(attribute, custom_opts)
          apply_theme!(:form_radio, rails_opts, error: field.error?)
          render_field(field, super(attribute, tag_value, rails_opts))
        end
      end
    end
  end
end
