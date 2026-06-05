# frozen_string_literal: true

require_relative "../../../form/field"

module StimulusPlumbers
  module Themes
    module Schema
      module Form
        module Ranges
          SUBMIT_TYPE      = %i[default button].freeze
          CHOICE_TYPE      = %i[default button card].freeze
          FLOATING_TYPE    = StimulusPlumbers::Form::Field::FLOATING_TYPES.freeze
          FIELD_TYPE       = StimulusPlumbers::Form::Field::TYPES
          COLLECTION_FIELD_TYPE = StimulusPlumbers::Form::Field::COLLECTION_TYPES
        end
      end
    end
  end
end
