# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module LinkHelper
      def sp_link(content = nil, **kwargs, &block)
        Components::Link.new(self).render(content, **kwargs, &block)
      end
    end
  end
end
