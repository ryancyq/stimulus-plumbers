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

      GEM_NAME        = StimulusPlumbers::Tailwind::Generators::SourcesDirective::GEM_NAME
      GEM_LIB_DIR     = "#{Gem.loaded_specs[GEM_NAME].gem_dir}/lib".freeze
      TOKENS_CSS_PATH = "app/assets/stylesheets/stimulus_plumbers/tokens.css"

      # ── happy path ────────────────────────────────────────────────────────────

      test "inserts @source after @import tailwindcss line" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @import "tailwindcss";
          @source "./app/views/**/*.erb";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          source_line = source_line_for("app/assets/stylesheets/application.tailwind.css")

          assert_includes css, "@import \"tailwindcss\";\n#{source_line}"
          assert_equal 1, css.scan(source_line).length
        end
      end

      test "appends @source when no @import tailwindcss line present" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @source "./app/views/**/*.erb";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_includes css, source_line_for("app/assets/stylesheets/application.tailwind.css")
        end
      end

      test "also injects the tokens.css import, ordered before @source" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @import "tailwindcss";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          tokens_line = tokens_line_for("app/assets/stylesheets/application.tailwind.css")
          source_line = source_line_for("app/assets/stylesheets/application.tailwind.css")

          assert_equal "#{tokens_line}\n@import \"tailwindcss\";\n#{source_line}\n", css
        end
      end

      test "keeps both directives idempotent across reruns" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")

        run_generator
        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_equal 1, css.scan("stimulus_plumbers/tokens.css").length
          assert_equal 1, css.scan(source_line_for("app/assets/stylesheets/application.tailwind.css")).length
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
          assert_includes css, source_line_for("app/assets/stylesheets/application.tailwind.css")
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
          assert_includes css, source_line_for("app/assets/stylesheets/application.tailwind.css")
        end
        assert_file "app/assets/stylesheets/application.css" do |css|
          assert_no_match %r{stimulus_plumbers_tailwind}, css
        end
      end

      test "falls back to tailwindcss-rails default entry when application.tailwind.css absent" do
        write_entry_css("app/assets/tailwind/application.css", "@import \"tailwindcss\";\n")

        run_generator

        assert_file "app/assets/tailwind/application.css" do |css|
          assert_includes css, source_line_for("app/assets/tailwind/application.css")
        end
      end

      test "falls back to application.css when application.tailwind.css absent" do
        write_entry_css("app/assets/stylesheets/application.css", "@import \"tailwindcss\";\n")

        run_generator

        assert_file "app/assets/stylesheets/application.css" do |css|
          assert_includes css, source_line_for("app/assets/stylesheets/application.css")
        end
      end

      test "falls back to javascript entrypoints candidate" do
        write_entry_css("app/javascript/entrypoints/application.css", "@import \"tailwindcss\";\n")

        run_generator

        assert_file "app/javascript/entrypoints/application.css" do |css|
          assert_includes css, source_line_for("app/javascript/entrypoints/application.css")
        end
      end

      test "falls through to candidates when STIMULUS_PLUMBERS_CSS_ENTRY points to non-existent file" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")

        with_env(
          StimulusPlumbers::Generators::CssEntrypoint::STIMULUS_PLUMBERS_CSS_ENTRY => "/nonexistent/path/application.css"
        ) do
          run_generator
        end

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_includes css, source_line_for("app/assets/stylesheets/application.tailwind.css")
        end
      end

      test "uses STIMULUS_PLUMBERS_CSS_ENTRY env var when set" do
        write_entry_css("app/assets/stylesheets/custom.css", "@import \"tailwindcss\";\n")
        custom_path = File.join(destination_root, "app/assets/stylesheets/custom.css")

        with_env(StimulusPlumbers::Generators::CssEntrypoint::STIMULUS_PLUMBERS_CSS_ENTRY => custom_path) do
          run_generator
        end

        assert_file "app/assets/stylesheets/custom.css" do |css|
          assert_includes css, source_line_for("app/assets/stylesheets/custom.css")
        end
      end

      # ── error handling ────────────────────────────────────────────────────────

      test "does not create or modify files when no entry file found" do
        run_generator

        StimulusPlumbers::Generators::CssEntrypoint::ENTRY_CANDIDATES.each do |candidate|
          assert_no_file candidate
        end
      end

      test "warns with all tried paths when no entry file found" do
        output = run_generator

        assert_match(%r{Could not find a Tailwind CSS entry file}, output)
        StimulusPlumbers::Generators::CssEntrypoint::ENTRY_CANDIDATES.each do |candidate|
          assert_includes output, File.join(destination_root, candidate)
        end
      end

      private

      def source_line_for(css_relative_path)
        css_dir = File.join(destination_root, File.dirname(css_relative_path))
        rel     = Pathname.new(GEM_LIB_DIR).relative_path_from(Pathname.new(css_dir))
        %(@source "#{rel}/**/*.rb";)
      end

      def tokens_line_for(css_relative_path)
        gem_dir = Gem.loaded_specs["stimulus_plumbers"].gem_dir
        css_dir = File.join(destination_root, File.dirname(css_relative_path))
        rel     = Pathname.new(File.join(gem_dir, TOKENS_CSS_PATH)).relative_path_from(Pathname.new(css_dir))
        %(@import "#{rel}";)
      end

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
