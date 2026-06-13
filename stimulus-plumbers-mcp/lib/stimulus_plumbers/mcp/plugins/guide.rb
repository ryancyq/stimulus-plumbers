# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    module Plugins
      module Guide
        extend Base

        LOADER_KEY = :guide
        LOADER     = GuideLoader

        STATIC_RESOURCES = [
          ::MCP::Resource.new(
            uri:         "guide://overview",
            name:        "overview",
            description: "Start here — how to build views and forms with stimulus-plumbers, with pointers to every tool/resource",
            mime_type:   "text/markdown"
          )
        ].freeze

        DYNAMIC_RESOURCE_TEMPLATES = [].freeze

        def self.read(uri, store)
          return unless uri == "guide://overview"

          text_resource(uri, "text/markdown", store[:guide])
        end
      end
    end
  end
end
