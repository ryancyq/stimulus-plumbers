# frozen_string_literal: true

module StimulusPlumbers
  module Generators
    module CssEntrypoint
      STIMULUS_PLUMBERS_CSS_FILE = "STIMULUS_PLUMBERS_CSS_FILE"

      def entry_css_file(candidates:, env_var:, fallback_env_var: nil)
        [env_var, fallback_env_var].compact.each do |var|
          next unless ENV[var]

          path = File.expand_path(ENV.fetch(var, nil))
          return path if File.exist?(path)
        end

        candidates
          .map { |c| File.join(destination_root, c) }
          .find { |f| File.exist?(f) }
      end

      def warn_entry_css_not_found(candidates:, env_var:, label:, fallback_env_var: nil)
        tried = candidates.map { |c| File.join(destination_root, c) }
        [env_var, fallback_env_var].compact.each do |var|
          tried.unshift(File.expand_path(ENV[var])) if ENV[var]
        end
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
