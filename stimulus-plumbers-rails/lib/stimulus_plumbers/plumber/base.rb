# frozen_string_literal: true

module StimulusPlumbers
  module Plumber
    class Base
      include ThemeOptions
      include StimulusOptions
      include AriaOptions
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
