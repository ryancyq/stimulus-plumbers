# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    # Path under the stimulus_plumbers gem's vendor/ dir (populated by bin/release),
    # used by loaders as their `gem exec` fallback when there's no monorepo checkout.
    module GemVendorPath
      GEM_NAME = "stimulus_plumbers"

      class << self
        def resolve(*relative)
          gem_dir = Gem::Specification.find_by_name(GEM_NAME).gem_dir
          File.join(gem_dir, "vendor", *relative)
        rescue Gem::MissingSpecError
          nil
        end
      end
    end
  end
end
