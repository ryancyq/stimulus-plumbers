# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ChecklistHelper
      def sp_checklist(...)
        Components::Checklist.new(self).render(...)
      end
    end
  end
end
