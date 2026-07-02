# frozen_string_literal: true

namespace :stimulus_plumbers do
  desc "Add the tokens.css @import into the CSS entry file"
  task(:install) do
    unless ENV["STIMULUS_PLUMBERS_SKIP_INSTALL"]
      require "generators/stimulus_plumbers/install/install_generator"
      StimulusPlumbers::Generators::InstallGenerator.new(
        [], {}, { destination_root: Rails.root.to_s }
      ).invoke_all
    end
  end
end

Rake::Task["stimulus_plumbers:install"].enhance(["environment"]) unless ENV["STIMULUS_PLUMBERS_SKIP_INSTALL"]

# Hooks into "assets:precompile" as a prerequisite; Rake merges rather than overwrites, so order-independent.
task "assets:precompile" => ["stimulus_plumbers:install"]
