# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Plumber
      class Base
        include HtmlOptions
        include Renderer

        attr_reader :template

        def initialize(template)
          @template = template
        end

        def theme
          StimulusPlumbers.config.theme
        end
      end
    end
  end
end
