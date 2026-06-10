# frozen_string_literal: true

require "active_support/concern"
require_relative "token_list"

module StimulusPlumbers
  module Plumber
    module Options
      module Theme
        extend ActiveSupport::Concern
        include TokenList

        def merge_theme_options(*hashes)
          merge_token_list(*hashes.flat_map { |h| [h[:class], h[:classes]] }).presence
        end
      end
    end
  end
end
