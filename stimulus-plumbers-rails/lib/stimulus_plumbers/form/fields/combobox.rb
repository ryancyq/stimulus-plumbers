# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Combobox
        TYPES = %i[date].freeze

        def combobox_field(attribute, type:, **options)
          unless TYPES.include?(type)
            raise ArgumentError, "unsupported combobox type #{type.inspect}. Must be one of: #{TYPES.join(", ")}"
          end

          rails_opts, field_opts = extract_options(options)
          field = build_field(attribute, field_opts)
          ids   = combobox_ids(attribute)

          trigger_data, value_data = combobox_target_data(type)

          content = combobox_popup(type, ids, rails_opts)
          shell   = Components::Combobox::Renderer.new(@template).render(
            name:         field_name(attribute),
            value:        object&.public_send(attribute),
            content:      content,
            popup_id:     ids[:popup_id],
            trigger_data: trigger_data,
            value_data:   value_data,
            **field_theme(:form_combobox, error: field.error?),
            **field.html_opts
          )
          render_field(field, shell)
        end

        private

        def combobox_ids(attribute)
          base = field_id(attribute)
          { calendar_id: "#{base}_calendar", popup_id: "#{base}_popup" }
        end

        # Returns [trigger_data, value_data] extra data attributes per combobox type.
        # These cross-wire the shared trigger/value inputs to the type controller's targets.
        def combobox_target_data(type)
          case type
          when :date
            [
              { input_datepicker_target: "display" },
              { input_datepicker_target: "input" }
            ]
          else
            [{}, {}]
          end
        end

        def combobox_popup(type, ids, opts)
          case type
          when :date
            Components::Combobox::Date.new(@template).render(**ids, **opts)
          end
        end
      end
    end
  end
end
