# frozen_string_literal: true

require "fileutils"
require "json"

namespace :build do
  desc "Generate vendor/component/manifest.json from this gem's data-action/-target/-value usage"
  task :manifest do
    require_relative "support/component_manifest"

    js_manifest_path = File.expand_path("../../stimulus-plumbers/dist/controllers.manifest.json", __dir__)
    abort "  Missing #{js_manifest_path} — run `npm run build` in stimulus-plumbers/ first." unless File.exist?(js_manifest_path)

    known_identifiers = JSON.parse(File.read(js_manifest_path)).keys
    manifest = StimulusPlumbers::ComponentManifest.call(known_identifiers: known_identifiers)

    vendor_dir = File.expand_path("../vendor/component", __dir__)
    FileUtils.mkdir_p(vendor_dir)
    File.write(File.join(vendor_dir, "manifest.json"), JSON.pretty_generate(manifest))

    puts "Written #{manifest.size} controller wiring entries to vendor/component/manifest.json"
  end
end

namespace :manifest do
  desc "Build the JS controller manifest and this gem's component manifest if missing"
  task :ensure do
    js_dir = File.expand_path("../../stimulus-plumbers", __dir__)
    js_manifest = File.join(js_dir, "dist/controllers.manifest.json")
    sh "node --run build:manifest", chdir: js_dir unless File.exist?(js_manifest)

    component_manifest = File.expand_path("../vendor/component/manifest.json", __dir__)
    Rake::Task["build:manifest"].invoke unless File.exist?(component_manifest)
  end
end

task "test:unit" => %w[manifest:ensure]
task "test:unit:coverage" => %w[manifest:ensure]
