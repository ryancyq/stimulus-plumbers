# frozen_string_literal: true

require "test_helper"

class EngineTest < Minitest::Test
  def test_assets_initializer_skips_precompile_when_assets_config_is_absent
    app = Struct.new(:config).new(Object.new)

    assert_silent do
      StimulusPlumbers::Engine.initializers
                              .find { |i| i.name == "stimulus_plumbers.assets" }
                              .run(app)
    end
  end

  # sprockets (assets pipeline) is only present in Rails < 7.0 in this project
  if defined?(Rails::Engine) && Rails.version < "7.0"
    def test_booted_app_precompile_includes_tokens_css
      assert_includes Rails.application.config.assets.precompile, "stimulus_plumbers/tokens.css"
    end
  end

  def test_rake_tasks_file_exists_and_defines_install_task
    rake_file = File.expand_path("../../lib/tasks/stimulus_plumbers.rake", __dir__)

    assert_path_exists rake_file
    assert_includes File.read(rake_file), "stimulus_plumbers:install"
  end
end
