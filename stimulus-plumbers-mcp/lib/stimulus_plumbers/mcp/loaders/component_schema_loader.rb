# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class ComponentSchemaLoader
      # Not derivable from Form::Fields::Renderer's method names (`search:` renders via
      # `render_combobox_typeahead`, but wires up "combobox-dropdown", not
      # "combobox-typeahead") — hand-maintained; keep in sync with form.md's "backed by" notes.
      FIELD_AS_CONTROLLERS = {
        date:                      "combobox-date",
        time:                      "combobox-time",
        select:                    "combobox-dropdown",
        search:                    "combobox-dropdown",
        collection_select:         "combobox-dropdown",
        grouped_collection_select: "combobox-dropdown"
      }.freeze

      class << self
        def call
          {
            components:           extract_schema,
            field_as:             extract_field_as,
            field_as_controllers: FIELD_AS_CONTROLLERS,
            controllers:          ComponentRequirements.call
          }
        end

        private

        def extract_schema
          Themes::Base::SCHEMA.transform_values do |param_schema|
            param_schema.transform_values do |meta|
              v = meta[:validate]
              { default: meta[:default], valid: v.respond_to?(:to_a) ? v.to_a : v.inspect }
            end
          end
        end

        def extract_field_as
          {
            field:            Form::Fields::Renderer::FIELD.keys,
            collection_field: Form::Fields::Renderer::COLLECTION.keys,
            choice:           Form::Fields::Renderer::CHOICE.keys
          }
        end
      end
    end
  end
end
