# frozen_string_literal: true

require "test_helper"

class EngineTest < Minitest::Test
  def test_does_not_register_tokens_css_as_a_standalone_precompile_asset
    refute(StimulusPlumbers::Engine.initializers.any? { |initializer| initializer.name == "stimulus_plumbers.assets" })
  end

  def test_rake_tasks_file_exists_and_defines_install_task
    rake_file = File.expand_path("../../lib/tasks/stimulus_plumbers.rake", __dir__)

    assert_path_exists rake_file
    assert_includes File.read(rake_file), "stimulus_plumbers:install"
  end
end
