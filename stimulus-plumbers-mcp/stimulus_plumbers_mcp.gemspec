# frozen_string_literal: true

require_relative "lib/stimulus_plumbers/mcp/version"

Gem::Specification.new do |spec|
  spec.name = "stimulus_plumbers_mcp"
  spec.version = StimulusPlumbers::MCP::VERSION
  spec.authors = ["Ryan Chang"]
  spec.email = ["ryancyq@gmail.com"]

  spec.summary     = "MCP server for the stimulus-plumbers UI library"
  spec.description = "A local MCP server that exposes the stimulus-plumbers API schema and documentation to LLM-powered IDEs"
  spec.homepage    = "https://github.com/ryancyq/stimulus-plumbers"
  spec.license     = "MIT"

  # Run-from-clone dev tool, not a published gem — bundler loads it via the
  # `gemspec` directive (require_paths), so there is no publish/packaging metadata.
  spec.files         = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0"

  spec.add_dependency "actionview", ">= 6.1"
  spec.add_dependency "mcp", ">= 0.8"
  spec.add_dependency "stimulus_plumbers"
  spec.add_dependency "stimulus_plumbers_tailwind"
end
