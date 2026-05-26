# frozen_string_literal: true

require_relative "external"

module StimulusPlumbers
  module Themes
    module Tailwind
      module Icons
        module Heroicon
          include External
          extend self

          private

          def svg_dir
            @svg_dir ||= begin
              require "heroicons"
              File.join(Heroicons.root, "app/assets/images/heroicons")
            rescue LoadError
              File.expand_path("heroicons", __dir__)
            end
          end

          def svg_defaults(key)
            key.end_with?("/solid") ? { fill: "currentColor", stroke: "none" } : {}
          end

          def svg_path(key)
            variant = key.end_with?("/solid") ? "solid" : "outline"
            File.join(svg_dir, variant, "#{key.delete_suffix("/solid")}.svg")
          end
        end
      end
    end
  end
end
