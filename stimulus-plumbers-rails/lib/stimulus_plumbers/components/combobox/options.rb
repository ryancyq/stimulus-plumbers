# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Options < Plumber::Base
        def render(...)
          render_options(...)
        end

        def label_for(items, value)
          return nil if value.to_s.empty?

          normalize_items(items, value.to_s).each do |item|
            options = item.key?(:optgroup) ? normalize_items(item[:optgroup][:options], value.to_s) : [item]
            match = options.find { |option| option[:selected] }
            return match[:label] if match
          end
          nil
        end

        private

        def render_options(items, value: nil, id_prefix: nil, &block)
          @selected_value = value&.to_s
          @id_prefix      = id_prefix
          @option_index   = 0
          @group_index    = 0
          render_items(items, &block)
        end

        def render_items(items, &block)
          template.safe_join(normalize_items(items, @selected_value).map { |item| render_item(item, &block) })
        end

        def render_item(item, &block)
          return template.capture(item, &block) if block

          if item.key?(:optgroup)
            group = item[:optgroup]
            OptionGroup.new(template).render(label: group[:label], id: next_id("group")) do
              render_items(group[:options])
            end
          else
            Option.new(template).render(**item, id: next_id("option"))
          end
        end

        def next_id(kind)
          return nil unless @id_prefix

          index = kind == "group" ? (@group_index += 1) : (@option_index += 1)
          "#{@id_prefix}_#{kind}_#{index}"
        end

        def normalize_items(items, selected_value)
          Array(items).filter_map { |item| normalize_item(item, selected_value) }
        end

        def normalize_item(item, selected_value)
          case item
          when Hash  then normalize_hash(item, selected_value)
          when Array then normalize_option(item[0], item[1].to_s, item[2] || {}, selected_value)
          else
            StimulusPlumbers::Logger.warn("Options#normalize_item: unrecognized item type #{item.class}, skipping")
            nil
          end
        end

        def normalize_hash(item, selected_value)
          if item.key?(:options)
            { optgroup: { label: item[:label], options: item[:options] } }
          else
            normalize_option(item[:label], item[:value].to_s, item, selected_value)
          end
        end

        def normalize_option(label, value, attrs, selected_value)
          {
            label:       label,
            value:       value,
            # Blank selects nothing.
            selected:    !selected_value.to_s.empty? && selected_value == value,
            disabled:    attrs[:disabled] || false,
            description: attrs[:description]
          }
        end
      end
    end
  end
end
