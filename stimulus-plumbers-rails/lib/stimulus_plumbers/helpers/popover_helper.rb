# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module PopoverHelper
      def sp_popover(...)
        popover_renderer.render(...)
      end

      private

      def popover_renderer
        Components::Popover.new(self)
      end
    end
  end
end
