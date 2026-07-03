# frozen_string_literal: true

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
