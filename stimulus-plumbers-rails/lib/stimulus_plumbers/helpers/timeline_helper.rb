# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module TimelineHelper
      def sp_timeline(...)
        Components::Timeline.new(self).render(...)
      end

      def sp_timeline_group(...)
        Components::Timeline::Group.new(self).render(...)
      end
    end
  end
end
