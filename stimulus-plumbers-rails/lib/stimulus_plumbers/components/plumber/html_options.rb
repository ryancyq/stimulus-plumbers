# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Components
    module Plumber
      module HtmlOptions
        extend ActiveSupport::Concern

        def merge_html_options(defaults = {}, **overrides)
          merged = defaults.deep_merge(overrides)
          result = { class: merge_class_options(merged) }
          result.deep_merge!(merged)
          result
        end

        private

        def merge_class_options(hash)
          return unless hash.key?(:class) || hash.key?(:classes)

          merge_string_option(hash.delete(:class), hash.delete(:classes))
        end

        def merge_string_option(*args, delimiter: " ", **kwargs)
          merged = args.flat_map { |arg| normalize_arg(arg, delimiter) }
          merged.concat(kwargs.filter_map { |key, val| key if val })
          merged.compact.uniq.join(delimiter)
        end

        def normalize_arg(arg, delimiter)
          case arg
          when String then arg.present? ? arg.split(delimiter) : []
          when Hash then arg.filter_map { |key, val| key if val }
          when Array then [merge_string_option(*arg).presence]
          else []
          end
        end
      end
    end
  end
end
