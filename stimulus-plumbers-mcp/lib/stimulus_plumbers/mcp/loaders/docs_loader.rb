# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class DocsLoader
      DOCS_DIR = File.expand_path(
        "../../../../../stimulus-plumbers-rails/docs/component",
        __dir__
      )

      def self.call
        Dir[File.join(DOCS_DIR, "*.md")].each_with_object({}) do |path, result|
          name = File.basename(path, ".md").to_sym
          content = File.read(path)
          result[name] = {
            content:   content,
            examples:  extract_erb_examples(content),
            signature: extract_signature(content)
          }
        end
      end

      def self.extract_erb_examples(content)
        content.scan(%r{```erb\n(.*?)```}m).map(&:first).map(&:strip)
      end

      # Parse `| Option |` / `| Slot method |` doc tables into the helper surface.
      # Options are grouped under the heading (sub-helper signature) above them.
      def self.extract_signature(content)
        tables = tables_with_headings(content)
        { helpers: option_helpers(tables), slots: slot_methods(tables) }
      end

      def self.option_helpers(tables)
        tables.select { |t| t[:header].first == "Option" }
              .filter_map do |t|
                options = t[:rows].map { |r| option_row(r) }
                { signature: t[:heading], options: options } unless options.empty?
              end
      end

      def self.slot_methods(tables)
        tables.select { |t| t[:header].first == "Slot method" }
              .flat_map { |t| t[:rows].map { |r| slot_row(r) } }
      end

      def self.option_row(cells)
        { option: clean(cells[0]), default: clean(cells[1]), description: cells[2].to_s }
      end

      def self.slot_row(cells)
        slot = clean(cells[0])
        description = cells[1].to_s
        { slot: slot, description: description, block: block_required?(slot, description) }
      end

      def self.block_required?(slot, description)
        slot.include?("{") || description.match?(%r{block required}i)
      end

      # Tag each table with the heading above it; skip fenced code (so ```ruby
      # comments aren't read as headings).
      def self.tables_with_headings(content)
        state = { heading: nil, fenced: false, buffer: [], tables: [] }
        content.each_line { |line| scan_line(line, state) }
        flush_table(state)
        state[:tables]
      end

      def self.scan_line(line, state)
        if line.start_with?("```")
          flush_table(state)
          state[:fenced] = !state[:fenced]
        elsif state[:fenced]
          nil
        elsif (heading = line[%r{\A#+\s+(.+)}, 1])
          flush_table(state)
          state[:heading] = clean(heading)
        elsif line.lstrip.start_with?("|")
          state[:buffer] << line
        else
          flush_table(state)
        end
      end

      def self.flush_table(state)
        return if state[:buffer].empty?

        state[:tables] << build_table(state[:buffer]).merge(heading: state[:heading])
        state[:buffer] = []
      end

      def self.build_table(lines)
        rows = lines.map { |l| split_row(l) }.reject { |cells| cells.all? { |c| c.match?(%r{\A:?-+:?\z}) } }
        { header: rows.first, rows: rows.drop(1) }
      end

      # Split a markdown table row, honouring escaped pipes (`\|`) inside cells.
      def self.split_row(line)
        line.strip.delete_prefix("|").delete_suffix("|")
            .split(%r{(?<!\\)\|})
            .map { |c| c.gsub('\|', "|").strip }
      end

      def self.clean(cell)
        cell.to_s.gsub(%r{[`*]}, "").sub(%r{:\z}, "").strip
      end

      private_class_method :option_helpers,
                           :slot_methods,
                           :option_row,
                           :slot_row,
                           :block_required?,
                           :tables_with_headings,
                           :scan_line,
                           :flush_table,
                           :build_table,
                           :split_row,
                           :clean
    end
  end
end
