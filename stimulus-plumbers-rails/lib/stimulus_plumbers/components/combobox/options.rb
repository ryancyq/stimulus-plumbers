# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Options < Plumber::Base
        def render(...)
          render_options(...)
        end

        private

        def render_options(items, value: nil, &block)
          @selected_value = value.to_s
          template.safe_join(items.filter_map { |item| render_item(item, &block) })
        end

        def render_item(item, &block)
          attrs = normalize_item(item)
          return nil if attrs.nil?

          if attrs.key?(:optgroup)
            block ? template.capture(attrs, &block) : OptionGroup.new(template).render(**attrs[:optgroup], value: @selected_value)
          else
            block ? template.capture(attrs, &block) : Option.new(template).render(**attrs)
          end
        end

        def normalize_item(item)
          case item
          when Hash  then normalize_hash(item)
          when Array then normalize_array(item)
          else
            StimulusPlumbers::Logger.warn("Options#normalize_item: unrecognized item type #{item.class}, skipping")
            nil
          end
        end

        def normalize_hash(item)
          if item.key?(:options)
            { optgroup: { label: item[:label], options: item[:options] } }
          else
            normalize_option(item[:label], item[:value].to_s, item)
          end
        end

        def normalize_array(item)
          normalize_option(item[0], item[1].to_s, item[2] || {})
        end

        def normalize_option(label, value, attrs)
          {
            label:       label,
            value:       value,
            selected:    @selected_value == value,
            disabled:    attrs[:disabled] || false,
            description: attrs[:description]
          }
        end
      end
    end
  end
end
