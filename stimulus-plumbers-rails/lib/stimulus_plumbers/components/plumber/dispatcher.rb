# frozen_string_literal: true

# :markup: markdown

module StimulusPlumbers
  module Components
    module Plumber
      module Dispatcher
        class MethodCall
          attr_reader :method_name, :args, :kwargs

          def initialize(method_name, *args, **kwargs)
            @method_name = method_name
            @args = args
            @kwargs = kwargs
            validate!
          end

          def call(target)
            raise NotImplementedError, "#{method_name.inspect} not implemented" unless target.respond_to?(method_name, true)

            method_call = target.method(method_name)
            accepts_args = method_call.arity.negative? ? args : args.take(method_call.arity)
            accepts_kwargs = method_call.parameters.any? { |type, _| %i[key keyreq keyrest].include?(type) }
            accepts_kwargs ? method_call.call(*accepts_args, **kwargs) : method_call.call(*accepts_args)
          end

          private

          def validate!
            return if method_name.is_a?(String) || method_name.is_a?(Symbol)

            raise ArgumentError, "invalid method name: #{method_name.inspect}"
          end
        end

        class InstanceExec
          attr_reader :block, :args, :kwargs

          def initialize(block, *args, **kwargs)
            @block = block
            @args = args
            @kwargs = kwargs
            validate!
          end

          def call(target)
            accepts_args = block.arity.negative? ? args : args.take(block.arity)
            accepts_kwargs = block.parameters.any? { |type, _| %i[key keyreq keyrest].include?(type) }
            if accepts_kwargs
              target.instance_exec(
                *accepts_args,
                **kwargs,
                &block
              )
            else
              target.instance_exec(*accepts_args, &block)
            end
          end

          private

          def validate!
            raise ArgumentError, "invalid block: #{block.inspect}" unless block.is_a?(Proc)
          end
        end

        class KlassProxy
          attr_reader :klass, :method_name, :args, :kwargs, :init_args, :init_kwargs

          def initialize(klass, method_name, *args, init_args: [], init_kwargs: {}, **kwargs)
            @klass = klass
            @method_name = method_name
            @args = args
            @kwargs = kwargs
            @init_args = init_args
            @init_kwargs = init_kwargs
            validate!
          end

          def call(_target)
            klass.new(*init_args, **init_kwargs).public_send(method_name, *args, **kwargs)
          end

          private

          def validate!
            raise ArgumentError, "invalid class: #{klass.inspect}" unless klass.is_a?(Module)
            return if method_name.is_a?(String) || method_name.is_a?(Symbol)

            raise ArgumentError, "invalid method name: #{method_name.inspect}"
          end
        end

        def self.build(callable, *args, method_name: nil, init_args: [], init_kwargs: {}, **kwargs)
          case callable
          when Symbol
            MethodCall.new(callable, *args, **kwargs)
          when Proc
            InstanceExec.new(callable, *args, **kwargs)
          when Module
            KlassProxy.new(callable, method_name, *args, init_args: init_args, init_kwargs: init_kwargs, **kwargs)
          when String
            klass = callable.safe_constantize
            raise ArgumentError, "could not resolve class from: #{callable.inspect}" unless klass

            KlassProxy.new(klass, method_name, *args, init_args: init_args, init_kwargs: init_kwargs, **kwargs)
          end
        end
      end
    end
  end
end
