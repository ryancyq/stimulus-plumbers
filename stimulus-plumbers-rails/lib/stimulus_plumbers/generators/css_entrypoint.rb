# frozen_string_literal: true

require "fileutils"

module StimulusPlumbers
  module Generators
    module CssEntrypoint
      STIMULUS_PLUMBERS_CSS_ENTRY = "STIMULUS_PLUMBERS_CSS_ENTRY"

      # Shared with stimulus_plumbers_tailwind's InstallGenerator — checked in order,
      # each path is another gem/tool's own default entry file. Detection is theme-
      # agnostic: any of these may be the CSS entry regardless of which theme is active.
      ENTRY_CANDIDATES = [
        "app/assets/stylesheets/application.tailwind.css", # tailwindcss-rails 2.x default
        "app/assets/tailwind/application.css",             # tailwindcss-rails 3.x+ default
        "app/assets/stylesheets/application.css",          # Rails/Propshaft default manifest
        "app/javascript/entrypoints/application.css"       # jsbundling-rails (esbuild/webpack) default
      ].freeze

      def entry_css_file(candidates:, env_var:)
        if ENV[env_var]
          path = File.expand_path(ENV.fetch(env_var, nil))
          return path if File.exist?(path)
        end

        candidates
          .map { |c| File.join(destination_root, c) }
          .find { |f| File.exist?(f) }
      end

      def warn_entry_css_not_found(candidates:, env_var:, label:)
        tried = candidates.map { |c| File.join(destination_root, c) }
        tried.unshift(File.expand_path(ENV[env_var])) if ENV[env_var]
        say "Could not find a #{label} entry file. Tried: #{tried.join(", ")}. " \
            "Set #{env_var}=/path/to/entry.css and re-run.",
            :red
      end

      def apply_edit(css_file, directive, stale_pattern:, anchor_pattern: nil)
        content              = File.read(css_file)
        new_content, status  = content_edit(content, directive, stale_pattern: stale_pattern, anchor_pattern: anchor_pattern)

        if new_content
          File.write(css_file, new_content)
          say_status status, relative_to_destination(css_file), :green
        else
          say_status :identical, relative_to_destination(css_file)
        end
      rescue Errno::EROFS, Errno::EACCES => e
        say "Could not update #{relative_to_destination(css_file)}: #{e.message}. Skipping.", :yellow
      end

      def remove_lines(css_file, pattern)
        content = File.read(css_file)
        return unless content.match?(pattern)

        File.write(css_file, content.lines.grep_v(pattern).join)
        say_status :update, relative_to_destination(css_file), :green
      rescue Errno::EROFS, Errno::EACCES => e
        say "Could not update #{relative_to_destination(css_file)}: #{e.message}. Skipping.", :yellow
      end

      def write_generated(path, contents)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, contents)
        say_status :create, relative_to_destination(path), :green
      rescue Errno::EROFS, Errno::EACCES => e
        say "Could not write #{relative_to_destination(path)}: #{e.message}. Skipping.", :yellow
      end

      def append_to_gitignore(path)
        gitignore = File.join(destination_root, ".gitignore")
        return unless File.exist?(gitignore)

        entry = "/#{relative_to_destination(path)}"
        return if File.readlines(gitignore, chomp: true).include?(entry)

        File.open(gitignore, "a") { |file| file.puts(entry) }
        say_status :append, ".gitignore", :green
      rescue Errno::EROFS, Errno::EACCES => e
        say "Could not update .gitignore: #{e.message}. Skipping.", :yellow
      end

      # CSS copied by an installer belongs to the application from this point on.
      # Keep an existing file intact so a generator rerun never overwrites local
      # customizations (the same policy used by tailwindcss-rails' installer).
      def copy_asset(source, destination)
        path = File.join(destination_root, destination)

        if File.exist?(path)
          say_status :identical, destination
          return true
        end

        FileUtils.mkdir_p(File.dirname(path))
        FileUtils.cp(source, path)
        say_status :create, destination, :green
        true
      rescue Errno::EROFS, Errno::EACCES => e
        say "Could not copy #{destination}: #{e.message}. Skipping.", :yellow
        false
      end

      # `stale_pattern:` is required — every call site needs stale-import detection,
      # so making it optional would leave an untested "anchor without stale" state.
      def content_edit(content, directive, stale_pattern:, anchor_pattern: nil)
        return nil if content.include?(directive)

        if (existing = content.match(stale_pattern))
          return [content.sub(existing[0], directive), :update]
        end

        anchor_pattern ? insert_near_anchor(content, directive, anchor_pattern) : prepend(content, directive)
      end

      def prepend(content, directive)
        ["#{directive}\n#{content}", :prepend]
      end

      def insert_near_anchor(content, directive, anchor_pattern)
        if (anchor = content.match(anchor_pattern))
          [content.sub(anchor[0], "#{anchor[0]}\n#{directive}"), :insert]
        else
          ["#{content.rstrip}\n#{directive}\n", :append]
        end
      end

      def relative_to_destination(path)
        path.delete_prefix("#{destination_root}/")
      end
    end
  end
end
