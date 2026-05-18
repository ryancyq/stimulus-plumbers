# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module DividerHelper
      def sp_divider(**html_options)
        Components::Divider.new(self).render(**html_options)
      end
    end
  end
end
