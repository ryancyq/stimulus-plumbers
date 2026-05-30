# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Plumber
    module AriaOptions
      extend ActiveSupport::Concern

      def labelled_aria(label, labelledby: nil)
        { label: (label unless labelledby), labelledby: labelledby }.compact
      end
    end
  end
end
