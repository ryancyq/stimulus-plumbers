# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Components
    module Plumber
      module Attributes
        extend ActiveSupport::Concern

        def html_options
          @html_options ||= {}
        end

        def html_options=(kwargs)
          html_options[:class] = merge_class_options(html_options[:class], kwargs)
          html_options.deep_merge!(kwargs) if kwargs.present?
        end

        private

        def merge_class_options(current, kwargs)
          return current unless kwargs.key?(:class) || kwargs.key?(:classes)

          merge_string_option(current, kwargs.delete(:class), kwargs.delete(:classes))
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
