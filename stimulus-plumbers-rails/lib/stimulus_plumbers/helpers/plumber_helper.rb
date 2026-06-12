# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module PlumberHelper
      def sp_dom_id(record = nil, prefix: nil, suffix: nil)
        base = record ? dom_id(record, prefix) : SecureRandom.hex(8)
        ["sp", base, suffix].compact.join("_")
      end
    end
  end
end
