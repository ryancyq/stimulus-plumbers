# frozen_string_literal: true

require "active_support/concern"
require_relative "theme"
require_relative "stimulus"

module StimulusPlumbers
  module Plumber
    module Options
      module Html
        extend ActiveSupport::Concern

        included do
          include Theme
          include Stimulus
        end

        def merge_html_options(*hashes)
          class_value = merge_theme_options(*hashes)
          merged_data = merge_stimulus_data(*hashes.map { |h| h[:data] || {} })
          rest        = hashes.map { |h| h.except(:class, :classes, :data) }.reduce({}, :deep_merge)

          result = class_value ? rest.merge(class: class_value) : rest
          merged_data.present? ? result.merge(data: merged_data) : result
        end
      end
    end
  end
end
