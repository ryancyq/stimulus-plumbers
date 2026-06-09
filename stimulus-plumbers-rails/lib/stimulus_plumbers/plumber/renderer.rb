# frozen_string_literal: true

require "active_support/concern"
require_relative "dispatcher"

module StimulusPlumbers
  module Plumber
    module Renderer
      extend ActiveSupport::Concern

      included do
        class_attribute :renderers, instance_writer: false, default: {}
      end

      def set_slots
        @set_slots ||= {}
      end

      def slot_renderable?(name)
        slots = set_slots[name]
        return false if slots.nil?
        return false if slots.is_a?(StimulusPlumbers::Plumber::Slots) && slots.none?
        return false if slots.is_a?(Array) && slots.empty?

        true
      end

      def slot_kwargs_for(name)
        case set_slots[name]
        when StimulusPlumbers::Plumber::Slots then { slot: set_slots[name] }
        when Array
          values = set_slots[name]
          { value: values.one? ? values.first : values }
        else {}
        end
      end

      def slot_block_for(name)
        slots = set_slots[name]
        slots if slots.is_a?(Proc)
      end

      module ClassMethods
        def renders(method_name, with: nil, slots: nil, by: nil, &block)
          validate!(method_name, with, slots, by, block_given?)
          with = block if block_given?

          if slots.present?
            by = Class.new(StimulusPlumbers::Plumber::Slots)
            by.slot(*slots)
          end
          self.renderers = renderers.merge(method_name => { with: with, by: by })

          generate_renderer_method(method_name)
          generate_slot_method(method_name)
        end

        private

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def validate!(method_name, with, slots, by, has_block)
          raise ArgumentError, "method_name must be a Symbol" unless method_name.is_a?(Symbol)
          raise ArgumentError, "provide either with: or a block, not both" if with && has_block
          raise ArgumentError, "slots: requires with:" if slots && with.nil? && !has_block
          raise ArgumentError, "by: requires with:" if by && with.nil?
          raise ArgumentError, "slots: and by: are mutually exclusive" if slots && by
          raise ArgumentError, "by: must be a Class" if by && !by.is_a?(Class)

          with_proc_or_symbol = with.is_a?(Proc) || with.is_a?(Symbol)
          with_klazz = with.is_a?(Module) || with.is_a?(String)
          raise ArgumentError, "with: must be a Symbol/Proc/Class" unless with_proc_or_symbol || with_klazz || has_block
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        def generated_renderer_methods
          @generated_renderer_methods ||= Module.new.tap { |mod| prepend mod }
        end

        def generate_renderer_method(method_name)
          return eval_renderer_method(method_name) if ActiveSupport.version < "7.2"

          require "active_support/code_generator"
          ActiveSupport::CodeGenerator.batch(generated_renderer_methods, __FILE__, __LINE__) do |owner|
            owner.define_cached_method(:"render_#{method_name}", namespace: :plumber_renderers) do |batch|
              batch << renderer_method_template(method_name)
            end
          end
        end

        def eval_renderer_method(method_name)
          generated_renderer_methods.module_eval(renderer_method_template(method_name), __FILE__, __LINE__)
        end

        def renderer_method_template(method_name)
          <<-RUBY
          def render_#{method_name}(*args, **kwargs)
            return nil unless slot_renderable?(:#{method_name})

            renderer = renderers.fetch(:#{method_name}, {})
            target   = renderer[:with]
            unless target
              raise ArgumentError, "#render_#{method_name} not found" unless defined?(super)
              return super
            end

            dispatcher = StimulusPlumbers::Plumber::Dispatcher.build(
              target, *args,
              init_args: [template],
              init_kwargs: {},
              method_name: :render,
              **kwargs,
              **slot_kwargs_for(:#{method_name}),
              &slot_block_for(:#{method_name})
            )
            raise ArgumentError, "invalid renderer for :#{method_name}" unless dispatcher
            dispatcher.call(self)
          end
          RUBY
        end

        def generated_slot_methods
          @generated_slot_methods ||= Module.new.tap { |mod| prepend mod }
        end

        def generate_slot_method(method_name)
          return eval_slot_method(method_name) if ActiveSupport.version < "7.2"

          require "active_support/code_generator"
          ActiveSupport::CodeGenerator.batch(generated_slot_methods, __FILE__, __LINE__) do |owner|
            owner.define_cached_method(:"with_#{method_name}", namespace: :plumber_renderers) do |batch|
              batch << slot_setter_template(method_name)
            end
            owner.define_cached_method(:"#{method_name}", namespace: :plumber_renderers) do |batch|
              batch << slot_getter_template(method_name)
            end
            owner.define_cached_method(:"#{method_name}?", namespace: :plumber_renderers) do |batch|
              batch << slot_predicate_template(method_name)
            end
          end
        end

        def eval_slot_method(method_name)
          generated_slot_methods.module_eval(slot_setter_template(method_name), __FILE__, __LINE__)
          generated_slot_methods.module_eval(slot_getter_template(method_name), __FILE__, __LINE__)
          generated_slot_methods.module_eval(slot_predicate_template(method_name), __FILE__, __LINE__)
        end

        def slot_setter_template(method_name)
          <<-RUBY
          def with_#{method_name}(*values, &block)
            klass = renderers.dig(:#{method_name}, :by)
            if klass && block_given? && !block.arity.zero?
              builder = klass.new
              block.call(builder)
              set_slots[:#{method_name}] = builder
            elsif block_given?
              set_slots[:#{method_name}] = block
            else
              set_slots[:#{method_name}] = values
            end
            nil
          end
          RUBY
        end

        def slot_getter_template(method_name)
          <<-RUBY
          def #{method_name}
            set_slots[:#{method_name}]
          end
          RUBY
        end

        def slot_predicate_template(method_name)
          <<-RUBY
          def #{method_name}?
            slot_renderable?(:#{method_name})
          end
          RUBY
        end
      end
    end
  end
end
