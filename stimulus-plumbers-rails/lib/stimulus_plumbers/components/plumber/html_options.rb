# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Components
    module Plumber
      module HtmlOptions
        extend ActiveSupport::Concern

        def merge_html_options(*hashes)
          classes = hashes.flat_map { |h| [h[:class], h[:classes]] }
          rest    = hashes.map { |h| h.except(:class, :classes) }.reduce({}, :deep_merge)
          class_value = merge_string_option(*classes).presence
          class_value ? rest.merge(class: class_value) : rest
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
end
