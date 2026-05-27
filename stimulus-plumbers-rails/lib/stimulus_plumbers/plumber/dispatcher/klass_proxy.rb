# frozen_string_literal: true

module StimulusPlumbers
  module Plumber
    module Dispatcher
      class KlassProxy
        attr_reader :klass, :method_name, :args, :kwargs, :init_args, :init_kwargs, :block

        def initialize(klass, method_name, *args, init_args: [], init_kwargs: {}, **kwargs, &block)
          @klass       = klass
          @method_name = method_name
          @args        = args
          @kwargs      = kwargs
          @init_args   = init_args
          @init_kwargs = init_kwargs
          @block       = block
          validate!
        end

        def call(_target)
          klass.new(*init_args, **init_kwargs).public_send(method_name, *args, **kwargs, &@block)
        end

        private

        def validate!
          raise ArgumentError, "invalid class: #{klass.inspect}" unless klass.is_a?(Module)
          return if method_name.is_a?(String) || method_name.is_a?(Symbol)

          raise ArgumentError, "invalid method name: #{method_name.inspect}"
        end
      end
    end
  end
end
