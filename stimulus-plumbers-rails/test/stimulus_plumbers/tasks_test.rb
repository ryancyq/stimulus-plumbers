# frozen_string_literal: true

require "test_helper"
require "rake"

class TasksTest < Minitest::Test
  RAKE_FILE = File.expand_path("../../lib/tasks/stimulus_plumbers.rake", __dir__)

  def test_hooks_into_assets_precompile_when_already_defined
    with_fresh_rake_application do
      Rake::Task.define_task("assets:precompile")
      load RAKE_FILE

      assert_includes Rake::Task["assets:precompile"].prerequisites, "stimulus_plumbers:install"
    end
  end

  def test_hooks_into_assets_precompile_when_not_yet_defined
    with_fresh_rake_application do
      load RAKE_FILE

      assert_includes Rake::Task["assets:precompile"].prerequisites, "stimulus_plumbers:install"
    end
  end

  def test_install_task_depends_on_environment_by_default
    with_fresh_rake_application do
      load RAKE_FILE

      assert_includes Rake::Task["stimulus_plumbers:install"].prerequisites, "environment"
    end
  end

  def test_install_task_skips_environment_when_skip_env_var_set
    with_fresh_rake_application do
      with_env("STIMULUS_PLUMBERS_SKIP_INSTALL" => "1") do
        load RAKE_FILE

        assert_empty Rake::Task["stimulus_plumbers:install"].prerequisites
      end
    end
  end

  private

  def with_fresh_rake_application
    original = Rake.application
    Rake.application = Rake::Application.new
    yield
  ensure
    Rake.application = original
  end

  def with_env(vars)
    old = vars.to_h { |k, _| [k, ENV.fetch(k, nil)] }
    vars.each { |k, v| ENV[k] = v }
    yield
  ensure
    old.each { |k, v| ENV[k] = v }
  end
end
