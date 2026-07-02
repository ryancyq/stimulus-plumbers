# frozen_string_literal: true

module StimulusPlumbers
  module Plumber
    class Slots
      def self.slot(*names, by: nil)
        names.each do |name|
          by ? define_by_slot(name, by) : define_flat_slot(name)
          define_reader(name)
          define_predicate(name)
        end
      end

      def initialize(template = nil)
        @slots = {}
        @template = template
      end

      def resolve(name)
        entry = @slots[name]
        return unless entry

        value = entry[:value]
        value = capture_block(value) if value.is_a?(Proc)
        block_given? ? yield(value) : value
      end

      def options_for(name)
        (@slots[name] || {})[:options] || {}
      end

      def any?
        @slots.any?
      end

      def none?
        @slots.empty?
      end

      private

      # Runs the slot block through the view so its ERB output is returned,
      # not written to whatever buffer happens to be active.
      def capture_block(block)
        @template ? @template.capture(&block) : block.call
      end

      def set_slot(name, value, options = {})
        @slots[name] = { value: value, options: options }
      end

      class << self
        private

        def define_flat_slot(name)
          define_method(:"with_#{name}") do |value = nil, **opts, &block|
            set_slot(name, block || value, opts)
            nil
          end
        end

        def define_by_slot(name, by)
          define_method(:"with_#{name}") do |&block|
            sub = by.new(@template)
            block&.call(sub)
            set_slot(name, sub)
            nil
          end
        end

        def define_reader(name)
          define_method(name) { resolve(name) }
        end

        def define_predicate(name)
          define_method(:"#{name}?") { @slots.key?(name) }
        end
      end
    end
  end
end
