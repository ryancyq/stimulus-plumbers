# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module OrderedListHelper
      def sp_ordered_list(...)
        Components::OrderedList.new(self).render(...)
      end
    end
  end
end
