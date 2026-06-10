# frozen_string_literal: true

require_relative "options/html"
require_relative "options/aria"
require_relative "renderer"

module StimulusPlumbers
  module Plumber
    class Base
      include Options::Html
      include Options::Aria
      include Renderer

      attr_reader :template

      def initialize(template)
        @template = template
      end

      def theme
        StimulusPlumbers.config.theme.current
      end
    end
  end
end
