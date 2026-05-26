# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module DividerHelper
      def sp_divider(label = nil, **kwargs)
        Components::Divider.new(self).render(label, **kwargs)
      end
    end
  end
end
