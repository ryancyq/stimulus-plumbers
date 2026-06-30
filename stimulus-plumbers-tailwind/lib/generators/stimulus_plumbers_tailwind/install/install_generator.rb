# frozen_string_literal: true

require "rails/generators"

module StimulusPlumbersTailwind
  module Generators
    class InstallGenerator < Rails::Generators::Base
      GEM_NAME          = "stimulus_plumbers_tailwind"
      TAILWIND_CSS_FILE = "TAILWIND_CSS_FILE"
      CSS_CANDIDATES    = %w[
        app/assets/stylesheets/application.tailwind.css
        app/assets/stylesheets/application.css
        app/javascript/entrypoints/application.css
      ].freeze

      def install
        css_file = entry_css_file
        unless css_file
          tried = CSS_CANDIDATES.map { |c| File.join(destination_root, c) }
          tried.unshift(File.expand_path(ENV[TAILWIND_CSS_FILE])) if ENV[TAILWIND_CSS_FILE]
          say "Could not find a Tailwind CSS entry file. Tried: #{tried.join(", ")}. " \
              "Set #{TAILWIND_CSS_FILE}=/path/to/entry.css and re-run.", :red
          return
        end

        source_line = build_source_line
        content     = File.read(css_file)

        if content.include?(source_line)
          say_status :identical, relative_to_destination(css_file)
        elsif (existing = content.match(/@source "[^"]*#{Regexp.escape(GEM_NAME)}[^"]*";/))
          File.write(css_file, content.sub(existing[0], source_line))
          say_status :update, relative_to_destination(css_file), :green
        elsif (import_line = content.match(/@import "tailwindcss"[^;]*;/))
          File.write(css_file, content.sub(import_line[0], "#{import_line[0]}\n#{source_line}"))
          say_status :insert, relative_to_destination(css_file), :green
        else
          File.write(css_file, "#{content.rstrip}\n#{source_line}\n")
          say_status :append, relative_to_destination(css_file), :green
        end
      end

      private

      def build_source_line
        spec = Gem.loaded_specs[GEM_NAME]
        %(@source "#{spec.gem_dir}/lib/**/*.rb";)
      end

      def entry_css_file
        if ENV[TAILWIND_CSS_FILE]
          path = File.expand_path(ENV[TAILWIND_CSS_FILE])
          return path if File.exist?(path)
        end

        CSS_CANDIDATES
          .map { |c| File.join(destination_root, c) }
          .find { |f| File.exist?(f) }
      end

      def relative_to_destination(path)
        path.delete_prefix("#{destination_root}/")
      end
    end
  end
end
