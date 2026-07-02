# frozen_string_literal: true

namespace :stimulus_plumbers do
  namespace :tailwind do
    desc "Add @source directive for stimulus_plumbers_tailwind into Tailwind CSS entry file"
    task(:install) do
      unless ENV["STIMULUS_PLUMBERS_SKIP_INSTALL"]
        require "generators/stimulus_plumbers/tailwind/install/install_generator"
        StimulusPlumbers::Tailwind::Generators::InstallGenerator.new(
          [], {}, { destination_root: Rails.root.to_s }
        ).invoke_all
      end
    end
  end
end

Rake::Task["stimulus_plumbers:tailwind:install"].enhance(["environment"]) unless ENV["STIMULUS_PLUMBERS_SKIP_INSTALL"]

# Hooks into these tasks as a prerequisite; Rake merges rather than overwrites, so order-independent.
task "assets:precompile" => ["stimulus_plumbers:tailwind:install"]
task "tailwindcss:build" => ["stimulus_plumbers:tailwind:install"]
