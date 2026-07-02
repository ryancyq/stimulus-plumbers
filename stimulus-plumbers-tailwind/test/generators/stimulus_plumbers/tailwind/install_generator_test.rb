# frozen_string_literal: true

require "test_helper"
require "rails/generators/test_case"
require "generators/stimulus_plumbers/tailwind/install/install_generator"

module StimulusPlumbers
  module Tailwind
    class InstallGeneratorTest < Rails::Generators::TestCase
      tests StimulusPlumbers::Tailwind::Generators::InstallGenerator
      destination File.join(Dir.tmpdir, "stimulus_plumbers_tailwind_generator_test")
      setup :prepare_destination

      GEM_NAME          = StimulusPlumbers::Tailwind::Generators::InstallGenerator::GEM_NAME
      TAILWIND_CSS_FILE = StimulusPlumbers::Tailwind::Generators::InstallGenerator::TAILWIND_CSS_FILE
      GEM_LIB_GLOB  = "#{Gem.loaded_specs[GEM_NAME].gem_dir}/lib/**/*.rb".freeze
      SOURCE_LINE   = %(@source "#{GEM_LIB_GLOB}";).freeze
      TOKENS_CSS_PATH = "/app/assets/stylesheets/stimulus_plumbers/tokens.css"
      TOKENS_LINE = %(@import "#{Gem.loaded_specs["stimulus_plumbers"].gem_dir}#{TOKENS_CSS_PATH}";).freeze

      # ── happy path ────────────────────────────────────────────────────────────

      test "inserts @source after @import tailwindcss line" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @import "tailwindcss";
          @source "./app/views/**/*.erb";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_includes css, "@import \"tailwindcss\";\n#{SOURCE_LINE}"
          assert_equal 1, css.scan(SOURCE_LINE).length
        end
      end

      test "appends @source when no @import tailwindcss line present" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @source "./app/views/**/*.erb";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_includes css, SOURCE_LINE
        end
      end

      test "also injects the tokens.css import, ordered before @source" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @import "tailwindcss";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_equal "#{TOKENS_LINE}\n@import \"tailwindcss\";\n#{SOURCE_LINE}\n", css
        end
      end

      test "keeps both directives idempotent across reruns" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")

        run_generator
        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_equal 1, css.scan("stimulus_plumbers/tokens.css").length
          assert_equal 1, css.scan(SOURCE_LINE).length
        end
      end

      # ── idempotency ───────────────────────────────────────────────────────────

      test "does not duplicate @source when run twice" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")

        run_generator
        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_equal 1, css.scan("@source").length
        end
      end

      test "updates stale @source when gem path has changed" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @import "tailwindcss";
          @source "/old/gems/stimulus_plumbers_tailwind-0.0.1/lib/**/*.rb";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_includes css, SOURCE_LINE
          assert_no_match %r{old/gems}, css
          assert_equal 1, css.scan("@source").length
        end
      end

      # ── entry file detection ──────────────────────────────────────────────────

      test "detects application.tailwind.css as first candidate" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")
        write_entry_css("app/assets/stylesheets/application.css", "@import \"tailwindcss\";\n")

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_includes css, SOURCE_LINE
        end
        assert_file "app/assets/stylesheets/application.css" do |css|
          assert_no_match %r{stimulus_plumbers_tailwind}, css
        end
      end

      test "falls back to application.css when application.tailwind.css absent" do
        write_entry_css("app/assets/stylesheets/application.css", "@import \"tailwindcss\";\n")

        run_generator

        assert_file "app/assets/stylesheets/application.css" do |css|
          assert_includes css, SOURCE_LINE
        end
      end

      test "falls back to javascript entrypoints candidate" do
        write_entry_css("app/javascript/entrypoints/application.css", "@import \"tailwindcss\";\n")

        run_generator

        assert_file "app/javascript/entrypoints/application.css" do |css|
          assert_includes css, SOURCE_LINE
        end
      end

      test "falls through to candidates when TAILWIND_CSS_FILE points to non-existent file" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")

        with_env(TAILWIND_CSS_FILE => "/nonexistent/path/application.css") do
          run_generator
        end

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_includes css, SOURCE_LINE
        end
      end

      test "uses TAILWIND_CSS_FILE env var when set" do
        write_entry_css("app/assets/stylesheets/custom.css", "@import \"tailwindcss\";\n")
        custom_path = File.join(destination_root, "app/assets/stylesheets/custom.css")

        with_env(TAILWIND_CSS_FILE => custom_path) do
          run_generator
        end

        assert_file "app/assets/stylesheets/custom.css" do |css|
          assert_includes css, SOURCE_LINE
        end
      end

      # ── error handling ────────────────────────────────────────────────────────

      test "does not create or modify files when no entry file found" do
        run_generator

        StimulusPlumbers::Tailwind::Generators::InstallGenerator::CSS_CANDIDATES.each do |candidate|
          assert_no_file candidate
        end
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
end
