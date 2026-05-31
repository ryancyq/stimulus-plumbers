# frozen_string_literal: true

require_relative "../../../form/field"

module StimulusPlumbers
  module Themes
    module Schema
      module Form
        module Ranges
          LAYOUT                = %i[stacked inline].freeze
          SUBMIT_VARIANT        = %i[default button].freeze
          CHOICE_VARIANT        = %i[default button card].freeze
          FIELD_TYPE            = StimulusPlumbers::Form::Field::TYPES
          COLLECTION_FIELD_TYPE = StimulusPlumbers::Form::Field::COLLECTION_TYPES
        end
      end
    end
  end
end
