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

    # No rails rake task builds this; mirrors bin/release's copy. Refresh when the copy is
    # missing or older than the JS manifest, so a stale vendor copy from an earlier branch
    # can't shadow freshly built controllers.
    rails_controller_vendor = File.join(rails_dir, "vendor/controller")
    rails_controller_manifest = File.join(rails_controller_vendor, "manifest.json")
    if !File.exist?(rails_controller_manifest) || File.mtime(js_manifest) > File.mtime(rails_controller_manifest)
      sh "mkdir -p #{rails_controller_vendor}"
      sh "cp #{js_manifest} #{rails_controller_manifest}"
    end
  end
end

task "test:unit" => %w[manifest:ensure]
task "coverage:run" => %w[manifest:ensure]
