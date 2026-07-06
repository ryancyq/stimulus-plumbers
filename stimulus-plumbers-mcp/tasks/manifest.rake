# frozen_string_literal: true

namespace :manifest do
  desc "Build sibling controller/component manifests if missing (JS dist manifest, Rails vendor manifest)"
  task :ensure do
    root = File.expand_path("../..", __dir__)

    js_dir = File.join(root, "stimulus-plumbers")
    js_manifest = File.join(js_dir, "dist/controllers.manifest.json")
    sh "node --run build:manifest", chdir: js_dir unless File.exist?(js_manifest)

    rails_dir = File.join(root, "stimulus-plumbers-rails")
    rails_manifest = File.join(rails_dir, "vendor/component/manifest.json")
    sh "bundle exec rake build:manifest", chdir: rails_dir unless File.exist?(rails_manifest)
  end
end

task test: %w[manifest:ensure]
task "coverage:run" => %w[manifest:ensure]
