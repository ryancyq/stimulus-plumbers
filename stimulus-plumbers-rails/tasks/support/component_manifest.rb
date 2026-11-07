# frozen_string_literal: true

require "pathname"
require "active_support/core_ext/enumerable"
require_relative "ruby_source"

module StimulusPlumbers
  # Dev/CI/release-only: scans this gem's lib/ for data-action/-target/-value wiring
  # strings and summarizes, per Stimulus controller identifier, what Ruby actually
  # references. Mirrors the npm package's controllers.manifest.json shape so the two
  # can be diffed — see test/stimulus_plumbers/stimulus_contract_test.rb. Not required
  # by lib/stimulus_plumbers.rb — only used by `rake build:manifest` (tasks/manifest.rake)
  # and its test, never shipped in the released gem.
  #
  # Extraction limitations (inherited from the same regex-based approach used for
  # controllers.manifest.json): dynamic identifiers that can't be statically
  # resolved to a constant (e.g. a local variable) are silently skipped, not
  # flagged — this generator produces data for a manifest, not developer warnings.
  # A class's `controller` or `self.class::STIMULUS_CONTROLLER` resolves to the
  # STIMULUS_CONTROLLER of the class and each subclass that defines one.
  class ComponentManifest
    RAILS_LIB = Pathname.new(__dir__).join("../../lib").expand_path

    TOKEN_RE = /
      (?:(?<src>[\w-]+|\#\{[^}]*\}):)?
      (?:(?<event>[\w.]+)->)?
      (?<target>[\w-]+|\#\{[^}]*\})
      \#(?<method>[a-zA-Z_]\w*)
    /x

    INHERITED_CONTROLLER = %r{\A(?:controller|self\.class::STIMULUS_CONTROLLER)\z}
    TARGET_RE = /(?<q1>["'])(?<id>[\w-]+|\#\{[^}]*\})-target\k<q1>\s*(?:=>|:)\s*(?<q2>["'])(?<names>[^"']*)\k<q2>/
    VALUE_KEY_RE = %r{["'](?<key>[\w-]+-value)["']}

    class << self
      def call(known_identifiers:)
        consts = build_const_table(RAILS_LIB)
        const_table = consts.merge(inherited_controllers(RAILS_LIB, consts))
        manifest = known_identifiers.index_with { { "actions" => [], "listens" => [], "targets" => [], "values" => [] } }

        RAILS_LIB.glob("**/*.rb").each { |file| scan_file(file, const_table, known_identifiers, manifest) }

        manifest.transform_values { |entry| entry.transform_values { |arr| arr.uniq.sort } }
      end

      private

      def scan_file(file, const_table, known_identifiers, manifest)
        stacks = RubySource.nesting_stack(file)
        file.readlines.each_with_index do |line, idx|
          nesting = stacks[idx]
          extract_actions(line, nesting, const_table, manifest)
          extract_targets(line, nesting, const_table, manifest)
          extract_values(line, known_identifiers, manifest)
        end
      end

      # ─── Shared with bin/audit-action-contract's constant-resolution approach ──

      def build_const_table(root)
        table = {}
        root.glob("**/*.rb").each do |file|
          lines = file.readlines
          stacks = RubySource.nesting_stack(file)
          lines.each_with_index do |line, idx|
            next unless (m = line.match(%r{^\s*([A-Z][A-Z0-9_]*)\s*=\s*"([^"]+)"}))

            table[(stacks[idx] + [m[1]]).join("::")] = m[2]
          end
        end
        table
      end

      # "<Class>::<inherited>" => the STIMULUS_CONTROLLER of Class and each subclass that defines one.
      def inherited_controllers(root, consts)
        RubySource.ancestors(root).each_with_object({}) do |(name, ancestors), table|
          id = consts["#{name}::STIMULUS_CONTROLLER"]
          [name, *ancestors].each { |base| (table["#{base}::<inherited>"] ||= []) << id } if id
        end
      end

      # Identifiers an interpolation names: one constant, or each subclass's controller.
      def resolve_all(identifier, const_table, nesting)
        return [identifier] unless identifier.start_with?('#{')

        inner = identifier[2..-2]
        return inherited_ids(nesting, const_table) if inner.match?(INHERITED_CONTROLLER)
        return [] if inner =~ %r{^[a-z]}

        nesting.size.downto(0) do |i|
          key = (nesting.first(i) + [inner]).join("::")
          return [const_table[key]] if const_table.key?(key)
        end
        []
      end

      def inherited_ids(nesting, const_table)
        nesting.size.downto(1) do |i|
          ids = const_table["#{nesting.first(i).join("::")}::<inherited>"]
          return ids if ids
        end
        []
      end

      # ─── Extraction ─────────────────────────────────────────────────────────

      def extract_actions(line, nesting, const_table, manifest)
        line.scan(%r{"([^"]*)"}) do |(str)|
          next unless str.include?("->") || str =~ %r{\A[\w-]+#[a-zA-Z_]\w*\z}

          str.scan(TOKEN_RE) { extract_action_token(Regexp.last_match, nesting, const_table, manifest) }
        end
      end

      def extract_action_token(token, nesting, const_table, manifest)
        targets = resolve_all(token[:target], const_table, nesting).select { |id| manifest.key?(id) }
        return if targets.empty?

        # `src:event->target#method` is a listen on src *and* an action on target.
        extract_listen_token(token, nesting, const_table, manifest) if token[:src]
        targets.each { |target| manifest[target]["actions"] << token[:method] }
      end

      def extract_listen_token(token, nesting, const_table, manifest)
        return unless token[:event]

        resolve_all(token[:src], const_table, nesting).each do |src|
          manifest[src]["listens"] << token[:event] if manifest.key?(src)
        end
      end

      def extract_targets(line, nesting, const_table, manifest)
        line.scan(TARGET_RE) do
          m = Regexp.last_match
          resolve_all(m[:id], const_table, nesting).each do |id|
            manifest[id]["targets"].concat(m[:names].split) if manifest.key?(id)
          end
        end
      end

      # Value names are embedded in the key itself (data-<id>-<name>-value), so
      # resolution is a longest-prefix match against known_identifiers rather
      # than constant lookup — the key is almost always a literal string.
      def extract_values(line, known_identifiers, manifest)
        line.scan(VALUE_KEY_RE) do |(key)|
          bare = key.sub(%r{-value\z}, "")
          id = known_identifiers.select { |k| bare.start_with?("#{k}-") }.max_by(&:length)
          next unless id

          value_name = bare.sub("#{id}-", "")
          manifest[id]["values"] << value_name.gsub(%r{-([a-z])}) { Regexp.last_match(1).upcase }
        end
      end
    end
  end
end
