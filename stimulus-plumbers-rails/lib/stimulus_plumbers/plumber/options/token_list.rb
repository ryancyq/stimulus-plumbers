# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Plumber
    module Options
      module TokenList
        extend ActiveSupport::Concern

        def merge_token_list(*parts, delimiter: " ")
          tokens = parts.flat_map { |part| normalize_part(part, delimiter) }
          tokens.compact.uniq.join(delimiter)
        end

        private

        def normalize_part(value, delimiter)
          case value
          when String then value.present? ? value.split(delimiter) : []
          when Hash   then value.filter_map { |key, val| key if val }
          when Array  then [merge_token_list(*value).presence]
          else []
          end
        end
      end
    end
  end
end
