# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class IconsLoader
      class << self
        def call
          heroicon_dir = Themes::Tailwind::Icons::Heroicon.send(:svg_dir)
          custom_dir   = Themes::Tailwind::Icons::Custom.send(:svg_dir)

          (outline_names(heroicon_dir) + solid_names(heroicon_dir) + custom_names(custom_dir) + alias_names).uniq.sort
        end

        private

        def outline_names(heroicon_dir)
          Dir[File.join(heroicon_dir, "outline", "*.svg")].map { |f| File.basename(f, ".svg") }
        end

        def solid_names(heroicon_dir)
          Dir[File.join(heroicon_dir, "solid", "*.svg")].map { |f| "#{File.basename(f, ".svg")}/solid" }
        end

        def custom_names(custom_dir)
          Dir[File.join(custom_dir, "*.svg")].map { |f| File.basename(f, ".svg") }
        end

        def alias_names
          Themes::Tailwind::Icon::ALIASES.keys
        end
      end
    end
  end
end
