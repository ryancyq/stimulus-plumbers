# frozen_string_literal: true

require_relative "lib/stimulus_plumbers/tailwind/version"

Gem::Specification.new do |spec|
  spec.name = "stimulus_plumbers_tailwind"
  spec.version = StimulusPlumbers::Tailwind::VERSION
  spec.authors = ["Ryan Chang"]
  spec.email = ["ryancyq@gmail.com"]

  spec.summary     = "Tailwind CSS theme for stimulus_plumbers"
  spec.description = "Extends stimulus_plumbers with a Tailwind CSS v4 theme"
  spec.homepage    = "https://github.com/ryancyq/stimulus-plumbers"
  spec.license     = "MIT"

  spec.metadata = {
    "rubygems_mfa_required" => "true",
    "allowed_push_host"     => "https://rubygems.org",
    "changelog_uri"         => "https://github.com/ryancyq/stimulus-plumbers/blob/main/CHANGELOG.md",
    "homepage_uri"          => spec.homepage,
    "source_code_uri"       => "https://github.com/ryancyq/stimulus-plumbers/tree/main/stimulus-plumbers-tailwind"
  }

  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).select do |f|
      f.start_with?(*%w[app/ lib/ LICENSE README.md CHANGELOG.md])
    end
  end

  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0"
  spec.required_rubygems_version = ">= 3.2.0"

  spec.add_dependency "stimulus_plumbers", ">= 0.3.1"
end
