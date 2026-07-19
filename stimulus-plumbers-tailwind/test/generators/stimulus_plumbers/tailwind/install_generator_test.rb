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

      TOKENS_CSS_PATH     = "app/assets/stylesheets/stimulus_plumbers/tokens.css"
      ANIMATIONS_CSS_PATH = "app/assets/stylesheets/stimulus_plumbers/tailwind/animations.css"
      SOURCES_CSS_PATH    = "app/assets/builds/stimulus_plumbers/tailwind.css"

      # ── happy path ────────────────────────────────────────────────────────────

      test "inserts sources.css import after @import tailwindcss line" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @import "tailwindcss";
          @source "./app/views/**/*.erb";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          source_line = sources_import_for("app/assets/stylesheets/application.tailwind.css")

          assert_includes css, "@import \"tailwindcss\";\n#{source_line}"
          assert_equal 1, css.scan(source_line).length
        end
      end

      test "appends sources.css import when no @import tailwindcss line present" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @source "./app/views/**/*.erb";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_includes css, sources_import_for("app/assets/stylesheets/application.tailwind.css")
        end
      end

      test "also injects the tokens.css and animations.css imports, ordered before @source" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @import "tailwindcss";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          tokens_line     = tokens_line_for("app/assets/stylesheets/application.tailwind.css")
          animations_line = animations_line_for("app/assets/stylesheets/application.tailwind.css")
          source_line     = sources_import_for("app/assets/stylesheets/application.tailwind.css")

          assert_equal "#{tokens_line}\n#{animations_line}\n@import \"tailwindcss\";\n#{source_line}\n", css
        end
        assert_file TOKENS_CSS_PATH, File.read(StimulusPlumbers::Tailwind::Generators::InstallGenerator::TOKENS_CSS_SOURCE)
        assert_file ANIMATIONS_CSS_PATH, File.read(StimulusPlumbers::Tailwind::Generators::InstallGenerator::ANIMATIONS_CSS_SOURCE)
        assert_file SOURCES_CSS_PATH, sources_contents_for(SOURCES_CSS_PATH)
      end

      test "inserts the animations.css import right after the tokens.css import" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @import "tailwindcss";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          tokens_line     = tokens_line_for("app/assets/stylesheets/application.tailwind.css")
          animations_line = animations_line_for("app/assets/stylesheets/application.tailwind.css")

          assert_includes css, "#{tokens_line}\n#{animations_line}"
        end
      end

      test "updates stale @import animations.css when gem path has changed" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @import "tailwindcss";
          @import "/old/gems/stimulus_plumbers_tailwind-0.0.1/app/assets/stylesheets/stimulus_plumbers/tailwind/animations.css";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_includes css, animations_line_for("app/assets/stylesheets/application.tailwind.css")
          assert_no_match %r{old/gems}, css
          assert_equal 1, css.scan("stimulus_plumbers/tailwind/animations.css").length
        end
      end

      test "keeps all three directives idempotent across reruns" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")

        run_generator
        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_equal 1, css.scan("stimulus_plumbers/tokens.css").length
          assert_equal 1, css.scan("stimulus_plumbers/tailwind/animations.css").length
          assert_equal 1, css.scan(sources_import_for("app/assets/stylesheets/application.tailwind.css")).length
        end
      end

      test "preserves existing app-owned CSS files on rerun" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")
        write_entry_css(TOKENS_CSS_PATH, "/* local tokens */\n")
        write_entry_css(ANIMATIONS_CSS_PATH, "/* local animations */\n")

        run_generator

        assert_file TOKENS_CSS_PATH, "/* local tokens */\n"
        assert_file ANIMATIONS_CSS_PATH, "/* local animations */\n"
      end

      test "restores missing app-owned CSS files on rerun" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")

        run_generator
        File.delete(File.join(destination_root, TOKENS_CSS_PATH))
        File.delete(File.join(destination_root, ANIMATIONS_CSS_PATH))
        run_generator

        assert_file TOKENS_CSS_PATH, File.read(StimulusPlumbers::Tailwind::Generators::InstallGenerator::TOKENS_CSS_SOURCE)
        assert_file ANIMATIONS_CSS_PATH, File.read(StimulusPlumbers::Tailwind::Generators::InstallGenerator::ANIMATIONS_CSS_SOURCE)
      end

      # ── idempotency ───────────────────────────────────────────────────────────

      test "does not duplicate sources.css import when run twice" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")

        run_generator
        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_equal 1, css.scan(sources_import_for("app/assets/stylesheets/application.tailwind.css")).length
        end
      end

      test "migrates legacy inline @source when gem path has changed" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @import "tailwindcss";
          @source "/old/gems/stimulus_plumbers_tailwind-0.0.1/lib/**/*.rb";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_includes css, sources_import_for("app/assets/stylesheets/application.tailwind.css")
          assert_no_match %r{old/gems}, css
          refute_includes css, "@source"
        end
      end

      test "migrates the current machine's legacy inline @source" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @import "tailwindcss";
          #{legacy_source_line_for("app/assets/stylesheets/application.tailwind.css")}
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_includes css, sources_import_for("app/assets/stylesheets/application.tailwind.css")
          refute_includes css, "@source"
        end
      end

      test "migrates the prior entry-relative sources.css import" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @import "tailwindcss";
          @import "./stimulus_plumbers/tailwind/sources.css";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_includes css, sources_import_for("app/assets/stylesheets/application.tailwind.css")
          refute_includes css, "stimulus_plumbers/tailwind/sources.css"
        end
      end

      test "removes a legacy inline @source when sources.css is already imported" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @import "tailwindcss";
          #{sources_import_for("app/assets/stylesheets/application.tailwind.css")}
          @source "/old/gems/stimulus_plumbers_tailwind-0.0.1/lib/**/*.rb";
        CSS

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_equal 1, css.scan(sources_import_for("app/assets/stylesheets/application.tailwind.css")).length
          refute_includes css, "@source"
        end
      end

      test "overwrites sources.css on rerun" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")
        run_generator
        write_entry_css(SOURCES_CSS_PATH, "/* stale machine path */\n")

        run_generator

        assert_file SOURCES_CSS_PATH, sources_contents_for(SOURCES_CSS_PATH)
      end

      test "adds sources.css to an existing gitignore without duplicating it" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")
        write_entry_css(".gitignore", "log/\n")

        run_generator
        run_generator

        assert_file ".gitignore", "log/\n/#{SOURCES_CSS_PATH}\n"
      end

      test "does not add sources.css when an existing gitignore pattern covers it" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")
        write_entry_css(".gitignore", "app/assets/builds/*\n")

        assert system("git", "init", "-q", destination_root)

        run_generator

        assert_file ".gitignore", "app/assets/builds/*\n"
      end

      test "does not create a gitignore when one is absent" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")

        run_generator

        assert_no_file ".gitignore"
      end

      # ── entry file detection ──────────────────────────────────────────────────

      test "detects application.tailwind.css as first candidate" do
        write_entry_css("app/assets/stylesheets/application.tailwind.css", "@import \"tailwindcss\";\n")
        write_entry_css("app/assets/stylesheets/application.css", "@import \"tailwindcss\";\n")

        run_generator

        assert_file "app/assets/stylesheets/application.tailwind.css" do |css|
          assert_includes css, sources_import_for("app/assets/stylesheets/application.tailwind.css")
        end
        assert_file "app/assets/stylesheets/application.css" do |css|
          assert_no_match %r{stimulus_plumbers_tailwind}, css
        end
      end

      test "falls back to tailwindcss-rails default entry when application.tailwind.css absent" do
        write_entry_css("app/assets/tailwind/application.css", "@import \"tailwindcss\";\n")

        run_generator

        assert_file "app/assets/tailwind/application.css" do |css|
          assert_includes css, sources_import_for("app/assets/tailwind/application.css")
        end
      end

      test "falls back to application.css when application.tailwind.css absent" do
        write_entry_css("app/assets/stylesheets/application.css", "@import \"tailwindcss\";\n")

        run_generator

        assert_file "app/assets/stylesheets/application.css" do |css|
          assert_includes css, sources_import_for("app/assets/stylesheets/application.css")
        end
      end

      test "falls back to javascript entrypoints candidate" do
        write_entry_css("app/javascript/entrypoints/application.css", "@import \"tailwindcss\";\n")

        run_generator

        assert_file "app/javascript/entrypoints/application.css" do |css|
          assert_includes css, sources_import_for("app/javascript/entrypoints/application.css")
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
          assert_includes css, sources_import_for("app/assets/stylesheets/application.tailwind.css")
        end
      end

      test "uses STIMULUS_PLUMBERS_CSS_ENTRY env var when set" do
        write_entry_css("app/assets/stylesheets/custom.css", "@import \"tailwindcss\";\n")
        custom_path = File.join(destination_root, "app/assets/stylesheets/custom.css")

        with_env(StimulusPlumbers::Generators::CssEntrypoint::STIMULUS_PLUMBERS_CSS_ENTRY => custom_path) do
          run_generator
        end

        assert_file "app/assets/stylesheets/custom.css" do |css|
          assert_includes css, sources_import_for("app/assets/stylesheets/custom.css")
        end
      end

      # ── error handling ────────────────────────────────────────────────────────

      test "does not create or modify files when no entry file found" do
        run_generator

        StimulusPlumbers::Generators::CssEntrypoint::ENTRY_CANDIDATES.each do |candidate|
          assert_no_file candidate
        end
        assert_no_file TOKENS_CSS_PATH
        assert_no_file ANIMATIONS_CSS_PATH
        assert_no_file SOURCES_CSS_PATH
      end

      test "warns with all tried paths when no entry file found" do
        output = run_generator

        assert_match(%r{Could not find a Tailwind CSS entry file}, output)
        StimulusPlumbers::Generators::CssEntrypoint::ENTRY_CANDIDATES.each do |candidate|
          assert_includes output, File.join(destination_root, candidate)
        end
      end

      private

      def sources_import_for(css_relative_path)
        css_dir = File.join(destination_root, File.dirname(css_relative_path))
        StimulusPlumbers::Tailwind::Generators::SourcesDirective.import_directive(
          from: css_dir, destination_root: destination_root
        )
      end

      def sources_contents_for(sources_relative_path)
        sources_dir = File.join(destination_root, File.dirname(sources_relative_path))
        StimulusPlumbers::Tailwind::Generators::SourcesDirective.file_contents(from: sources_dir)
      end

      def legacy_source_line_for(css_relative_path)
        css_dir = File.join(destination_root, File.dirname(css_relative_path))
        StimulusPlumbers::Tailwind::Generators::SourcesDirective.source_line(from: css_dir)
      end

      def tokens_line_for(css_relative_path)
        css_dir = File.join(destination_root, File.dirname(css_relative_path))
        rel     = Pathname.new(File.join(destination_root, TOKENS_CSS_PATH)).relative_path_from(Pathname.new(css_dir))
        rel     = "./#{rel}" unless rel.to_s.start_with?(".", "/")
        %(@import "#{rel}";)
      end

      def animations_line_for(css_relative_path)
        css_dir = File.join(destination_root, File.dirname(css_relative_path))
        rel     = Pathname.new(File.join(destination_root, ANIMATIONS_CSS_PATH)).relative_path_from(Pathname.new(css_dir))
        rel     = "./#{rel}" unless rel.to_s.start_with?(".", "/")
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
