# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Schema
      module Ranges
        BOOL_RANGE   = [true, false].freeze
        SIZE_RANGE   = %i[sm md lg].freeze
        ALIGN_RANGE  = %i[left center right top bottom].freeze
        DIR_RANGE    = %i[row col].freeze
        LAYOUT_RANGE = %i[stacked inline].freeze
      end
    end
  end
end
