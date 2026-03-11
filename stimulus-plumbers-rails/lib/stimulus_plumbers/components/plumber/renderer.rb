# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Components
    module Plumber
      module Renderer
        extend ActiveSupport::Concern

        included do
          class_attribute :renderers, instance_writer: false, default: {}
        end

        module ClassMethods
          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def renders(method_name, with: nil, &block)
            raise ArgumentError, "method_name must be Symbol" unless method_name.is_a?(Symbol)
            raise ArgumentError, "provide either with: or a block" if !with.nil? && block_given?

            with = block if block_given?

            with_proc_or_symbol = with.is_a?(Proc) || with.is_a?(Symbol)
            with_klazz = with.is_a?(Module) || with.is_a?(String)
            raise ArgumentError, "with: must be a Symbol/Proc/Class" unless with_proc_or_symbol || with_klazz

            self.renderers = renderers.merge(method_name => with)
            ActiveSupport.version >= "7.2" ? generate_renderer_method(method_name) : eval_renderer_method(method_name)
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          private

          def generated_renderer_methods
            @generated_renderer_methods ||= Module.new.tap { |mod| prepend mod }
          end

          def eval_renderer_method(method_name)
            generated_renderer_methods.module_eval(<<-RUBY, __FILE__, __LINE__ + 1)
              # def method_name(*args, **kwargs)
              #   renderer = renderers.fetch(:method_name, {})
              #
              #   unless renderer.present?
              #     raise ArgumentError, "#method_name not found in renderer" unless defined?(super)
              #     super
              #   end
              #
              #   dispatcher = StimulusPlumbers::Components::Plumber::Dispatcher.build(
              #     renderer, *args, method_name: :#{method_name}, init_args: [template], **kwargs
              #   )
              #   raise ArgumentError, "invalid renderer, got: \#{renderer.inspect}" unless dispatcher
              #
              #   dispatcher.call(self)
              # end
              #{renderer_method_template(method_name)}
            RUBY
          end

          def generate_renderer_method(method_name)
            require "active_support/code_generator"
            ActiveSupport::CodeGenerator.batch(generated_renderer_methods, __FILE__, __LINE__) do |owner|
              owner.define_cached_method(method_name, namespace: :plumber_renderers) do |batch|
                batch << renderer_method_template(method_name)
              end
            end
          end

          def renderer_method_template(method_name)
            <<-RUBY
            def #{method_name}(*args, **kwargs)
              renderer = renderers.fetch(:#{method_name}, {})

              unless renderer.present?
                raise ArgumentError, "##{method_name} not found in renderer" unless defined?(super)
                super
              end

              dispatcher = StimulusPlumbers::Components::Plumber::Dispatcher.build(
                renderer, *args, method_name: :#{method_name}, init_args: [template], **kwargs
              )
              raise ArgumentError, "invalid renderer, got: \#{renderer.inspect}" unless dispatcher

              dispatcher.call(self)
            end
            RUBY
          end
        end
      end
    end
  end
end
