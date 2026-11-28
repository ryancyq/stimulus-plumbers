# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class ComponentSchemaLoader
      # Renderer method names don't give the controller, so this must match form.md's "backed by" notes.
      FIELD_AS_CONTROLLERS = {
        date:                      "combobox-date",
        time:                      "combobox-time",
        datetime:                  "combobox-datetime",
        select:                    "combobox",
        search:                    "combobox",
        collection_select:         "combobox",
        grouped_collection_select: "combobox"
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
