# frozen_string_literal: true

require_relative "lib/stimulus_plumbers/version"

Gem::Specification.new do |spec|
  spec.name = "stimulus_plumbers"
  spec.version = StimulusPlumbers::VERSION
  spec.authors = ["Ryan Chang"]
  spec.email = ["ryancyq@gmail.com"]

  spec.summary     = "Accessible ViewComponent components for Rails with Stimulus controllers"
  spec.description = "Semantically correct, accessible UI components for Rails using ViewComponent and Stimulus"
  spec.homepage    = "https://github.com/ryancyq/stimulus-plumbers"
  spec.license     = "MIT"

  spec.metadata = {
    "rubygems_mfa_required" => "true",
    "allowed_push_host"     => "https://rubygems.org",
    "changelog_uri"         => "https://github.com/ryancyq/stimulus-plumbers/blob/main/CHANGELOG.md",
    "homepage_uri"          => spec.homepage,
    "source_code_uri"       => "https://github.com/ryancyq/stimulus-plumbers/tree/main/stimulus-plumbers-rails"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # app/ assets (e.g. compiled JS dist) are resolved via Dir.glob since they are not git-tracked.
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).select do |f|
      f.start_with?(*%w[lib/ LICENSE README.md CHANGELOG.md])
    end
  end + Dir.glob("app/**/*", base: __dir__).reject { |f| File.directory?(File.join(__dir__, f)) }

  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.7"
  spec.required_rubygems_version = ">= 3.2.0" # for Gem::Platform#match_gem?

  spec.add_dependency "railties", ">= 6.1", "< 8.2"
  spec.add_dependency "view_component", "~> 3.0"
end
