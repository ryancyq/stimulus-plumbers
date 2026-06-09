# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Control
        BASE = %w[
          font-medium transition-colors
          focus-visible:outline-none
          focus-visible:ring-(length:--sp-focus-ring-width)
          focus-visible:ring-offset-(length:--sp-focus-ring-offset)
          disabled:pointer-events-none disabled:opacity-50
        ].freeze
      end
    end
  end
end
