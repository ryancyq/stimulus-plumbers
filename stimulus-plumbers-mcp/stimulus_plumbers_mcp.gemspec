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

  spec.metadata = {
    "rubygems_mfa_required" => "true",
    "allowed_push_host"     => "https://rubygems.org",
    "changelog_uri"         => "https://github.com/ryancyq/stimulus-plumbers/blob/main/CHANGELOG.md",
    "homepage_uri"          => spec.homepage,
    "source_code_uri"       => "https://github.com/ryancyq/stimulus-plumbers/tree/main/stimulus-plumbers-mcp"
  }

  spec.executables   = ["stimulus-plumbers-mcp"]
  spec.files         = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).select do |f|
      f.start_with?(*%w[lib/ bin/ LICENSE README.md CHANGELOG.md])
    end
  end
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0"

  spec.add_dependency "actionview", ">= 6.1"
  spec.add_dependency "mcp", ">= 0.8"
  spec.add_dependency "stimulus_plumbers"
  spec.add_dependency "stimulus_plumbers_tailwind"
end
