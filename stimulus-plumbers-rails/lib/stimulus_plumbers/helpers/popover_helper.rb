# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module PopoverHelper
      def sp_popover(...)
        Components::Popover.new(self).render(...)
      end
    end
  end
end
