# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module PlumberHelper
      def sp_dom_id(record = nil, suffix = nil)
        if record
          dom_id(record, suffix)
        else
          "#{suffix}_#{SecureRandom.hex(8)}"
        end
      end
    end
  end
end
