# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Schema
      module Button
        module Ranges
          TYPE    = %i[default outline ghost fab fab_outline dashed card].freeze
          SIZE    = %i[xs sm md lg xl].freeze
          LAYOUT  = %i[stacked inline].freeze
          VARIANT = %i[primary secondary tertiary success destructive warning info].freeze
        end
      end
    end
  end
end
