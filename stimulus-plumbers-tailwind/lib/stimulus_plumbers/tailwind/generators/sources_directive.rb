# frozen_string_literal: true

require "pathname"

module StimulusPlumbers
  module Tailwind
    module Generators
      module SourcesDirective
        GEM_NAME = "stimulus_plumbers_tailwind"
        LIB_DIR  = File.expand_path("../../..", __dir__)

        module_function

        def directive(from:)
          rel = Pathname.new(LIB_DIR).relative_path_from(Pathname.new(from))
          %(@source "#{rel}/**/*.rb";)
        end

        def anchor_pattern
          %r{@import "tailwindcss"[^;]*;}
        end

        def stale_pattern
          %r{@source "[^"]*#{Regexp.escape(GEM_NAME)}[^"]*";}
        end
      end
    end
  end
end
