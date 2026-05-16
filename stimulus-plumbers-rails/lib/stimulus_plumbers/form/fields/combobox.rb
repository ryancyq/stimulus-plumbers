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
          current_value = object&.public_send(attribute)

          wrapper = build_combobox_wrapper(klass, attribute, field, current_value, options, rails_opts)
          render_field(field, wrapper)
        end

        def build_combobox_wrapper(klass, attribute, field, current_value, options, rails_opts)
          popover = klass.new(@template).render(options: options, value: current_value, **rails_opts)
          opts    = klass.default_opts.deep_merge(
            input:   { name: field_name(attribute), value: current_value },
            popover: { content: popover }
          )
          Components::Combobox.new(@template).render(
            base_id: field_id(attribute),
            options: opts,
            **field_theme(:form_combobox, error: field.error?),
            **field.html_opts
          )
        end
      end
    end
  end
end
