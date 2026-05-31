# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Plumber
    module ThemeOptions
      extend ActiveSupport::Concern

      def merge_theme_options(*hashes)
        merge_string_option(*hashes.flat_map { |h| [h[:class], h[:classes]] }).presence
      end

      def merge_string_option(*parts, delimiter: " ")
        tokens = parts.flat_map { |part| normalize_part(part, delimiter) }
        tokens.compact.uniq.join(delimiter)
      end

      def normalize_part(value, delimiter)
        case value
        when String then value.present? ? value.split(delimiter) : []
        when Hash then value.filter_map { |key, val| key if val }
        when Array then [merge_string_option(*value).presence]
        else []
        end
      end
    end
  end
end
