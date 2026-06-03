# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ActionListHelper
      def sp_action_list(...)
        Components::ActionList.new(self).render(...)
      end
    end
  end
end
