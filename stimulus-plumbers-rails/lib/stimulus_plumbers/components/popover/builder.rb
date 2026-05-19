# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Popover
      class Builder
        attr_reader :activator_html, :content_html

        def initialize(template)
          @template = template
          @activator_html = nil
          @content_html   = nil
        end

        def activator(&block)
          @activator_html = @template.capture(&block)
        end

        def content(&block)
          @content_html = @template.capture(&block)
        end
      end
    end
  end
end
