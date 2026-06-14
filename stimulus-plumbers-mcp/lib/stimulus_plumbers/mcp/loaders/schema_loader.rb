# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class SchemaLoader
      def self.call
        {
          components: extract_schema,
          field_as:   extract_field_as,
          icons:      extract_icons,
          stimulus:   ComponentControllerMap.call
        }
      end

      def self.extract_schema
        Themes::Base::SCHEMA.transform_values do |param_schema|
          param_schema.transform_values do |meta|
            v = meta[:validate]
            { default: meta[:default], valid: v.respond_to?(:to_a) ? v.to_a : v.inspect }
          end
        end
      end

      def self.extract_field_as
        {
          field:            Form::Fields::Renderer::FIELD.keys,
          collection_field: Form::Fields::Renderer::COLLECTION.keys,
          choice:           Form::Fields::Renderer::CHOICE.keys
        }
      end

      def self.extract_icons
        heroicon_dir = Themes::Tailwind::Icons::Heroicon.send(:svg_dir)
        custom_dir   = Themes::Tailwind::Icons::Custom.send(:svg_dir)

        outline = Dir[File.join(heroicon_dir, "outline", "*.svg")].map { |f| File.basename(f, ".svg") }
        solid   = Dir[File.join(heroicon_dir, "solid",   "*.svg")].map { |f| "#{File.basename(f, ".svg")}/solid" }
        customs = Dir[File.join(custom_dir, "*.svg")].map { |f| File.basename(f, ".svg") }
        aliases = Themes::Tailwind::Icon::ALIASES.keys

        (outline + solid + customs + aliases).uniq.sort
      end
    end
  end
end
