# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module DividerHelper
      def sp_divider(label = nil, **html_options)
        Components::Divider.new(self).render(label, **html_options)
      end
    end
  end
end
