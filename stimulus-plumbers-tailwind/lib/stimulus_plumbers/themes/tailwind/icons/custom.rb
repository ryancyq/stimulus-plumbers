# frozen_string_literal: true

require_relative "external"

module StimulusPlumbers
  module Themes
    module Tailwind
      module Icons
        module Custom
          include External
          extend self

          private

          def svg_dir
            @svg_dir ||= File.expand_path("customs", __dir__)
          end

          def svg_path(key)
            File.join(svg_dir, "#{key}.svg")
          end
        end
      end
    end
  end
end
