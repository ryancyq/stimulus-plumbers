# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Builder
        def initialize(object, attribute)
          @object    = object
          @attribute = attribute
        end

        def call(opts)
          FieldComponent.new(
            object:           @object,
            attribute:        @attribute,
            label:            opts[:label],
            details:          opts[:details],
            error:            opts[:error],
            required:         opts.fetch(:required, false),
            disabled:         opts.fetch(:disabled, false),
            label_visibility: opts.fetch(:label_visibility, :visible),
            layout:           opts.fetch(:layout, :stacked),
            input_id:         opts[:input_id]
          )
        end
      end
    end
  end
end
