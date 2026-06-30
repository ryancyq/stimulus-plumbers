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
        return warn_entry_css_not_found unless css_file

        apply_edit(css_file)
      end

      private

      def warn_entry_css_not_found
        tried = CSS_CANDIDATES.map { |c| File.join(destination_root, c) }
        tried.unshift(File.expand_path(ENV[TAILWIND_CSS_FILE])) if ENV[TAILWIND_CSS_FILE]
        say "Could not find a Tailwind CSS entry file. Tried: #{tried.join(", ")}. " \
            "Set #{TAILWIND_CSS_FILE}=/path/to/entry.css and re-run.",
            :red
      end

      def apply_edit(css_file)
        content              = File.read(css_file)
        new_content, status  = content_edit(content, source_directive)

        if new_content
          File.write(css_file, new_content)
          say_status status, relative_to_destination(css_file), :green
        else
          say_status :identical, relative_to_destination(css_file)
        end
      end

      def content_edit(content, source_line)
        if content.include?(source_line)
          nil
        elsif (existing = content.match(%r{@source "[^"]*#{Regexp.escape(GEM_NAME)}[^"]*";}))
          [content.sub(existing[0], source_line), :update]
        elsif (import_line = content.match(%r{@import "tailwindcss"[^;]*;}))
          [content.sub(import_line[0], "#{import_line[0]}\n#{source_line}"), :insert]
        else
          ["#{content.rstrip}\n#{source_line}\n", :append]
        end
      end

      def source_directive
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
