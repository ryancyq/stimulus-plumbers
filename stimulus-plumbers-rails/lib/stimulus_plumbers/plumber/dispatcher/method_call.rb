# frozen_string_literal: true

module StimulusPlumbers
  module Plumber
    module Dispatcher
      class MethodCall
        include CallableInspector

        attr_reader :method_name, :args, :kwargs, :block

        def initialize(method_name, *args, **kwargs, &block)
          @method_name = method_name
          @args        = args
          @kwargs      = kwargs
          @block       = block
          validate!
        end

        def call(target)
          raise NotImplementedError, "#{method_name.inspect} not implemented" unless target.respond_to?(method_name, true)

          method_call = target.method(method_name)
          dispatched  = args_for(method_call)
          accepts_kwargs?(method_call) ? method_call.call(*dispatched, **kwargs, &@block) : method_call.call(*dispatched, &@block)
        end

        private

        def validate!
          return if method_name.is_a?(String) || method_name.is_a?(Symbol)

          raise ArgumentError, "invalid method name: #{method_name.inspect}"
        end
      end
    end
  end
end
