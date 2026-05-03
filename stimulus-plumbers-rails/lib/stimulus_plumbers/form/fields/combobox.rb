# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Combobox
        TYPES = %i[date dropdown autocomplete time].freeze

        def combobox_field(attribute, type:, options: [], **html_options)
          unless TYPES.include?(type)
            raise ArgumentError, "unsupported combobox type #{type.inspect}. Must be one of: #{TYPES.join(", ")}"
          end

          rails_opts, field_opts = extract_options(html_options)
          field = build_field(attribute, field_opts)
          ids   = combobox_ids(attribute, type)

          trigger_data, value_data = combobox_target_data(type)

          current_value = object&.public_send(attribute)
          content       = combobox_popover(type, ids, options, current_value, rails_opts)
          shell         = Components::Combobox::Renderer.new(@template).render(
            name:         field_name(attribute),
            value:        current_value,
            content:      content,
            popover_id:   ids[:popover_id],
            trigger_data: trigger_data,
            value_data:   value_data,
            **combobox_shell_options(type),
            **field_theme(:form_combobox, error: field.error?),
            **field.html_opts
          )
          render_field(field, shell)
        end

        private

        def combobox_ids(attribute, type)
          base = field_id(attribute)
          ids  = { popover_id: "#{base}_popover" }
          ids[:calendar_id] = "#{base}_calendar" if type == :date
          ids
        end

        def combobox_shell_options(type)
          case type
          when :date, :time
            { popover_role: "dialog", popover_tag: :div, popover_label: "Picker" }
          when :dropdown
            { popover_role: "listbox", popover_tag: :ul }
          when :autocomplete
            { popover_role: "listbox", popover_tag: :ul, trigger_readonly: false, aria_autocomplete: "list" }
          else
            {}
          end
        end

        # Cross-wires trigger/value inputs to the type-specific controller targets.
        def combobox_target_data(type)
          case type
          when :date
            [
              { input_datepicker_target: "display" },
              { input_datepicker_target: "input" }
            ]
          when :time
            [
              { input_timepicker_target: "display" },
              { input_timepicker_target: "input" }
            ]
          else
            [{}, {}]
          end
        end

        def combobox_popover(type, ids, options, current_value, opts)
          case type
          when :date
            Components::Combobox::Date.new(@template).render(**ids, **opts)
          when :dropdown
            Components::Combobox::Dropdown.new(@template).render(**ids, options: options, value: current_value, **opts)
          when :autocomplete
            Components::Combobox::Autocomplete.new(@template).render(**ids, options: options, value: current_value, **opts)
          when :time
            Components::Combobox::Time.new(@template).render(**ids, value: current_value, **opts)
          end
        end
      end
    end
  end
end
