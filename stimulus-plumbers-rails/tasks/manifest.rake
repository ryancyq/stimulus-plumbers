# frozen_string_literal: true

require "fileutils"
require "json"

def js_package_dir
  File.expand_path("../../stimulus-plumbers", __dir__)
end

def js_manifest_path
  File.join(js_package_dir, "dist/controllers.manifest.json")
end

def component_manifest_dir
  File.expand_path("../vendor/component", __dir__)
end

file js_manifest_path do
  sh "node --run build:manifest", chdir: js_package_dir
end

namespace :build do
  desc "Generate vendor/component/manifest.json from this gem's data-action/-target/-value usage"
  task manifest: js_manifest_path do
    require_relative "support/component_manifest"

    known_identifiers = JSON.parse(File.read(js_manifest_path)).keys
    manifest = StimulusPlumbers::ComponentManifest.call(known_identifiers: known_identifiers)

    FileUtils.mkdir_p(component_manifest_dir)
    File.write(File.join(component_manifest_dir, "manifest.json"), JSON.pretty_generate(manifest))

    puts "Written #{manifest.size} controller wiring entries to vendor/component/manifest.json"
  end
end

# Rebuilt every run — derived from this gem's own lib/, so a cached copy tests stale wiring.
task "test:unit" => %w[build:manifest]
task "test:unit:coverage" => %w[build:manifest]
