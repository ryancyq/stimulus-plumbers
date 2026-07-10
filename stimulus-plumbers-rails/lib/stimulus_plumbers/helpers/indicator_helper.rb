# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module IndicatorHelper
      def sp_indicator(variant: :primary, type: :dot, pulse: false, **kwargs, &block)
        Components::Indicator.new(self).render(type: type, variant: variant, pulse: pulse, **kwargs, &block)
      end
    end
  end
end
