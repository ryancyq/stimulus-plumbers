# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class DocsTableParser
      class << self
        def call(content)
          tables = tables_with_headings(content)
          { helpers: option_helpers(tables), slots: slot_methods(tables) }
        end

        # A standalone bold label (e.g. `**Time**`) between `#` headings is treated as a
        # sub-heading, since some docs use one to introduce a table scoped to part of a
        # section. It only labels the single table immediately following it — a fenced
        # code block or a second table both clear it, so it can't leak onto later tables.
        def tables_with_headings(content)
          state = { heading: nil, subheading: nil, fenced: false, buffer: [], tables: [] }
          content.each_line { |line| scan_line(line, state) }
          flush_table(state)
          state[:tables]
        end

        private

        def option_helpers(tables)
          tables.select { |t| t[:header].first == "Option" }
                .filter_map do |t|
                  options = t[:rows].map { |r| option_row(r, t[:header]) }
                  { signature: t[:heading], options: options } unless options.empty?
                end
        end

        def slot_methods(tables)
          tables.select { |t| t[:header].first == "Slot method" }
                .flat_map { |t| t[:rows].map { |r| slot_row(r) } }
        end

        # Column order varies across docs — locate by header name, not position.
        def option_row(cells, header)
          default_at = header.index("Default")
          {
            option:      clean(cells[0]),
            default:     default_at ? clean(cells[default_at]) : "",
            description: cells[header.index("Description") || 2].to_s
          }
        end

        def slot_row(cells)
          slot = clean(cells[0])
          description = cells[1].to_s
          { slot: slot, description: description, block: block_required?(slot, description) }
        end

        def block_required?(slot, description)
          slot.include?("{") || description.match?(%r{block required}i)
        end

        def scan_line(line, state)
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

        def toggle_fence(state)
          flush_table(state)
          state[:subheading] = nil
          state[:fenced] = !state[:fenced]
        end

        def set_heading(state, heading)
          flush_table(state)
          state[:heading] = clean(heading)
          state[:subheading] = nil
        end

        def set_subheading(state, subheading)
          flush_table(state)
          state[:subheading] = clean(subheading)
        end

        def flush_table(state)
          return if state[:buffer].empty?

          heading = [state[:heading], state[:subheading]].compact.join(" — ")
          state[:tables] << build_table(state[:buffer]).merge(heading: heading)
          state[:buffer] = []
          state[:subheading] = nil
        end

        def build_table(lines)
          rows = lines.map { |l| split_row(l) }.reject { |cells| cells.all? { |c| c.match?(%r{\A:?-+:?\z}) } }
          { header: rows.first, rows: rows.drop(1) }
        end

        # Split a markdown table row, honouring escaped pipes (`\|`) inside cells.
        def split_row(line)
          line.strip.delete_prefix("|").delete_suffix("|")
              .split(%r{(?<!\\)\|})
              .map { |c| c.gsub('\|', "|").strip }
        end

        def clean(cell)
          cell.to_s.gsub(%r{[`*]}, "").sub(%r{:\z}, "").strip
        end
      end
    end
  end
end
