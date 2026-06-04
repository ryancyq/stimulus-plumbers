# frozen_string_literal: true

require_relative "html_options"
require_relative "aria_options"
require_relative "renderer"
require_relative "icon_renderer"

module StimulusPlumbers
  module Plumber
    class Base
      include HtmlOptions
      include AriaOptions
      include Renderer
      include IconRenderer

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
