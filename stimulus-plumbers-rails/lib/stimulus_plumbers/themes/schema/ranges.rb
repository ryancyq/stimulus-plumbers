# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Schema
      module Ranges
        BOOL           = [true, false].freeze
        SIZE           = %i[xs sm md lg xl].freeze
        FLEX_ALIGN     = %i[left center right top bottom].freeze
        FLEX_DIRECTION = %i[row col].freeze
        BUTTON_TYPE    = %i[primary secondary tertiary outline ghost fab fab_outline dashed].freeze
        BUTTON_VARIANT = %i[default success destructive warning info].freeze
        LINK_VARIANT   = %i[default success destructive warning info].freeze
      end
    end
  end
end
