# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Combobox
        COMPONENT_CLASS = {
          autocomplete: Components::Combobox::Autocomplete,
          date:         Components::Combobox::Date,
          dropdown:     Components::Combobox::Dropdown,
          time:         Components::Combobox::Time
        }.freeze

        def combobox_field(attribute, type:, options: [], **html_options)
          klass = COMPONENT_CLASS.fetch(type) do
            raise ArgumentError,
                  "unsupported combobox type #{type.inspect}. Must be one of: #{COMPONENT_CLASS.keys.join(", ")}"
          end

          rails_opts, field_opts = extract_options(html_options)
          field         = build_field(attribute, field_opts)
          base_id       = field_id(attribute)
          current_value = object&.public_send(attribute)

          popover = klass.new(@template).render(options: options, value: current_value, **rails_opts)
          opts    = klass.default_opts.deep_merge(
            input:   { name: field_name(attribute), value: current_value },
            popover: { content: popover }
          )
          wrapper = Components::Combobox.new(@template).render(
            base_id: base_id,
            options: opts,
            **field_theme(:form_combobox, error: field.error?),
            **field.html_opts
          )
          render_field(field, wrapper)
        end
      end
    end
  end
end
