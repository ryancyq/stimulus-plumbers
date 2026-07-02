# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    # Parses `| Option |` / `| Slot method |` markdown tables out of a component doc
    # into the helper surface DocsLoader stores. Options are grouped under the
    # heading (sub-helper signature) above them.
    class DocsTableParser
      def self.call(content)
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
      # comments aren't read as headings). A standalone bold label (e.g. `**Time**`)
      # between `#` headings is treated as a sub-heading — some docs (form.md,
      # calendar.md) use bold labels instead of real headings to introduce a table
      # that only applies to part of the enclosing section. A sub-heading only
      # labels the single table immediately following it: a fenced code block
      # (an unrelated aside, e.g. "**Option formats:**" before a ruby example)
      # or a second table both clear it, so it doesn't leak onto later tables.
      def self.tables_with_headings(content)
        state = { heading: nil, subheading: nil, fenced: false, buffer: [], tables: [] }
        content.each_line { |line| scan_line(line, state) }
        flush_table(state)
        state[:tables]
      end

      def self.scan_line(line, state)
        if line.start_with?("```")
          toggle_fence(state)
        elsif state[:fenced]
          nil
        elsif (heading = line[%r{\A#+\s+(.+)}, 1])
          set_heading(state, heading)
        elsif (subheading = line[%r{\A\*\*([^*]+)\*\*}, 1])
          set_subheading(state, subheading)
        elsif line.lstrip.start_with?("|")
          state[:buffer] << line
        else
          flush_table(state)
        end
      end

      def self.toggle_fence(state)
        flush_table(state)
        state[:subheading] = nil
        state[:fenced] = !state[:fenced]
      end

      def self.set_heading(state, heading)
        flush_table(state)
        state[:heading] = clean(heading)
        state[:subheading] = nil
      end

      def self.set_subheading(state, subheading)
        flush_table(state)
        state[:subheading] = clean(subheading)
      end

      def self.flush_table(state)
        return if state[:buffer].empty?

        heading = [state[:heading], state[:subheading]].compact.join(" — ")
        state[:tables] << build_table(state[:buffer]).merge(heading: heading)
        state[:buffer] = []
        state[:subheading] = nil
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
                           :toggle_fence,
                           :set_heading,
                           :set_subheading,
                           :flush_table,
                           :build_table,
                           :split_row,
                           :clean
    end
  end
end
