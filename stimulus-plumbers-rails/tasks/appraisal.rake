# frozen_string_literal: true

# Runs bundle in a clean (non bundle-exec-polluted) environment so git-sourced
# gems (e.g. rails_edge.gemfile's rails/rails branch source) resolve correctly.
def bundle_lock_add_platform(gemfile, platform)
  Bundler.with_original_env do
    system({ "BUNDLE_GEMFILE" => gemfile }, "bundle", "lock", "--add-platform", platform)
  end
end

namespace :appraisal do
  desc "Add required platforms to all appraisal gemfiles"
  task :add_platforms do
    platforms = %w[
      arm64-darwin
      x64-mingw-ucrt
      x64-mingw32
      x86_64-darwin
      x86_64-linux
    ]
    gemfiles_dir = File.expand_path("../gemfiles", __dir__)

    Dir.glob("#{gemfiles_dir}/*.gemfile").each do |gemfile|
      puts "Adding platforms to #{File.basename(gemfile)}..."

      platforms.each do |platform|
        bundle_lock_add_platform(gemfile, platform) || exit(1)
      end
    end

    puts "\n✓ Successfully added platforms to all gemfiles"
  end

  desc "Install appraisal gemfiles and add platforms"
  task :setup do
    puts "Installing appraisal gemfiles..."
    system("bundle", "exec", "appraisal", "install") || exit(1)

    puts "\nAdding platforms to gemfiles..."
    Rake::Task["appraisal:add_platforms"].invoke
  end
end
