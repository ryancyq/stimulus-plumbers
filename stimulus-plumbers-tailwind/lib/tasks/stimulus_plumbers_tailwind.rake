# frozen_string_literal: true

namespace :stimulus_plumbers_tailwind do
  desc "Add @source directive for stimulus_plumbers_tailwind into Tailwind CSS entry file"
  task install: :environment do
    require "generators/stimulus_plumbers_tailwind/install/install_generator"
    StimulusPlumbersTailwind::Generators::InstallGenerator.new(
      [], {}, { destination_root: Rails.root.to_s }
    ).invoke_all
  end
end

Rake::Task["assets:precompile"].enhance(["stimulus_plumbers_tailwind:install"]) if Rake::Task.task_defined?("assets:precompile")

Rake::Task["tailwindcss:build"].enhance(["stimulus_plumbers_tailwind:install"]) if Rake::Task.task_defined?("tailwindcss:build")
