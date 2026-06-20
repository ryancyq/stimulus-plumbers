# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module TimelineHelper
      def sp_timeline(**kwargs, &block)
        Components::Timeline.new(self).render(**kwargs, &block)
      end
    end
  end
end
