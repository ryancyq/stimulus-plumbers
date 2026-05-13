# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module PopoverHelper
      def sp_popover(interactive: true, **html_options, &block)
        popover_renderer.render(interactive: interactive, **html_options, &block)
      end

      private

      def popover_renderer
        Components::Popover.new(self)
      end
    end
  end
end
