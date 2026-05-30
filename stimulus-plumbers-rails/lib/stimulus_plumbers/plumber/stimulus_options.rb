# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Plumber
    module StimulusOptions
      extend ActiveSupport::Concern

      STIMULUS_SPACEJOIN_KEYS = %i[controller action].freeze

      def merge_stimulus_data(*hashes, spacejoin: STIMULUS_SPACEJOIN_KEYS)
        hashes.reduce({}) do |acc, d|
          acc.merge(d) do |key, old_val, new_val|
            if spacejoin.include?(key.to_sym)
              merge_string_option(old_val, new_val).presence || new_val
            else
              new_val
            end
          end
        end
      end
    end
  end
end
