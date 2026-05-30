# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Plumber
    module ThemeOptions
      extend ActiveSupport::Concern

      def merge_html_options(*hashes)
        class_value = merge_string_option(*extract_classes(*hashes)).presence
        merged_data = merge_stimulus_data(*hashes.map { |h| h[:data] || {} })
        rest        = hashes.map { |h| h.except(:class, :classes, :data) }.reduce({}, :deep_merge)

        result = class_value ? rest.merge(class: class_value) : rest
        merged_data.present? ? result.merge(data: merged_data) : result
      end

      def extract_classes(*hashes)
        hashes.flat_map { |h| [h[:class], h[:classes]] }
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
