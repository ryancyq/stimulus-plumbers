# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Plumber
    module HtmlOptions
      extend ActiveSupport::Concern

      def merge_html_options(*hashes)
        classes     = hashes.flat_map { |h| [h[:class], h[:classes]] }
        data_hashes = hashes.map { |h| h[:data] || {} }
        rest        = hashes.map { |h| h.except(:class, :classes, :data) }.reduce({}, :deep_merge)

        class_value = merge_string_option(*classes).presence
        merged_data = merge_data_options(*data_hashes)

        result = class_value ? rest.merge(class: class_value) : rest
        merged_data.present? ? result.merge(data: merged_data) : result
      end

      STIMULUS_SPACEJOIN_KEYS = %i[controller action].freeze

      def merge_data_options(*hashes, spacejoin: STIMULUS_SPACEJOIN_KEYS)
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
