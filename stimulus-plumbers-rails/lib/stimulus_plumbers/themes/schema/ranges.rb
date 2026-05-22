# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Schema
      module Ranges
        BOOL           = [true, false].freeze
        SIZE           = %i[sm md lg].freeze
        FLEX_ALIGN     = %i[left center right top bottom].freeze
        FLEX_DIRECTION = %i[row col].freeze
        BUTTON_VARIANT = %i[primary secondary outline destructive ghost link fab dashed].freeze
      end
    end
  end
end
