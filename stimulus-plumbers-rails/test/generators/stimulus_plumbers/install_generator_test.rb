# frozen_string_literal: true

require "test_helper"
require "rails/generators/test_case"
require "generators/stimulus_plumbers/install/install_generator"

module StimulusPlumbers
  class InstallGeneratorTest < Rails::Generators::TestCase
    tests StimulusPlumbers::Generators::InstallGenerator
    destination File.join(Dir.tmpdir, "stimulus_plumbers_generator_test")
    setup :prepare_destination

    GEM_NAME    = "stimulus_plumbers"
    CSS_ENV_VAR = StimulusPlumbers::Generators::InstallGenerator::STIMULUS_PLUMBERS_CSS_FILE
    TOKENS_LINE = %(@import "#{Gem.loaded_specs[GEM_NAME].gem_dir}/app/assets/stylesheets/stimulus_plumbers/tokens.css";).freeze

    # ── happy path ────────────────────────────────────────────────────────────

    test "prepends tokens import as the first line" do
      write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")

      run_generator

      assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
        assert_equal "#{TOKENS_LINE}\n@import \"tailwindcss\";\n", css
      end
    end

    test "prepends tokens import even when no @import tailwindcss line exists" do
      write_entry_css("app/assets/stylesheets/application.css", ":root { --custom: 1; }\n")

      run_generator

      assert_file "app/assets/stylesheets/application.css" do |css|
        assert_equal "#{TOKENS_LINE}\n:root { --custom: 1; }\n", css
      end
    end

    # ── idempotency ───────────────────────────────────────────────────────────

    test "does not duplicate tokens import when run twice" do
      write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")

      run_generator
      run_generator

      assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
        assert_equal 1, css.scan("stimulus_plumbers/tokens.css").length
      end
    end

    test "updates stale tokens import when gem path has changed" do
      write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
        @import "/old/gems/stimulus_plumbers-0.0.1/app/assets/stylesheets/stimulus_plumbers/tokens.css";
        @import "tailwindcss";
      CSS

      run_generator

      assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
        assert_includes css, TOKENS_LINE
        assert_no_match %r{old/gems}, css
        assert_equal 1, css.scan("stimulus_plumbers/tokens.css").length
      end
    end

    # ── entry file detection ──────────────────────────────────────────────────

    test "detects application.tailwind.css as first candidate" do
      write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")
      write_entry_css("app/assets/stylesheets/application.css", "@import \"tailwindcss\";\n")

      run_generator

      assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
        assert_includes css, TOKENS_LINE
      end
      assert_file "app/assets/stylesheets/application.css" do |css|
        assert_no_match %r{stimulus_plumbers/tokens.css}, css
      end
    end

    test "falls back to application.css when application.tailwind.css absent" do
      write_entry_css("app/assets/stylesheets/application.css", "@import \"tailwindcss\";\n")

      run_generator

      assert_file "app/assets/stylesheets/application.css" do |css|
        assert_includes css, TOKENS_LINE
      end
    end

    test "falls back to javascript entrypoints candidate" do
      write_entry_css("app/javascript/entrypoints/application.css", "@import \"tailwindcss\";\n")

      run_generator

      assert_file "app/javascript/entrypoints/application.css" do |css|
        assert_includes css, TOKENS_LINE
      end
    end

    test "falls through to candidates when env var points to non-existent file" do
      write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")

      with_env(CSS_ENV_VAR => "/nonexistent/path/application.css") do
        run_generator
      end

      assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
        assert_includes css, TOKENS_LINE
      end
    end

    test "uses env var override when set" do
      write_entry_css("app/assets/stylesheets/custom.css", "@import \"tailwindcss\";\n")
      custom_path = File.join(destination_root, "app/assets/stylesheets/custom.css")

      with_env(CSS_ENV_VAR => custom_path) do
        run_generator
      end

      assert_file "app/assets/stylesheets/custom.css" do |css|
        assert_includes css, TOKENS_LINE
      end
    end

    # ── error handling ────────────────────────────────────────────────────────

    test "does not create or modify files when no entry file found" do
      run_generator

      StimulusPlumbers::Generators::InstallGenerator::CSS_CANDIDATES.each do |candidate|
        assert_no_file candidate
      end
    end

    test "does not raise when the entry file cannot be written to" do
      write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")
      css_path = File.join(destination_root, "app/assets/stylesheets/application.tailwind.css")
      File.chmod(0o444, css_path)

      output = run_generator

      assert_match(%r{Could not update}, output)
      assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
        assert_equal "@import \"tailwindcss\";\n", css
      end
    ensure
      File.chmod(0o644, css_path) if css_path && File.exist?(css_path)
    end

    private

    def write_entry_css(relative_path, content)
      full_path = File.join(destination_root, relative_path)
      FileUtils.mkdir_p(File.dirname(full_path))
      File.write(full_path, content)
    end

    def with_env(vars)
      old = vars.to_h { |k, _| [k, ENV.fetch(k, nil)] }
      vars.each { |k, v| ENV[k] = v }
      yield
    ensure
      old.each { |k, v| ENV[k] = v }
    end
  end
end
