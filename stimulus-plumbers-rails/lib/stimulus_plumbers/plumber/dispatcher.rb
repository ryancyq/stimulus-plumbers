# frozen_string_literal: true

require_relative "dispatcher/callable_inspector"
require_relative "dispatcher/method_call"
require_relative "dispatcher/instance_exec"
require_relative "dispatcher/klass_proxy"

module StimulusPlumbers
  module Plumber
    module Dispatcher
      class << self
        def build(callable, *args, method_name: nil, init_args: [], init_kwargs: {}, **kwargs, &block)
          case callable
          when Symbol
            MethodCall.new(callable, *args, **kwargs, &block)
          when Proc
            InstanceExec.new(callable, *args, **kwargs)
          when Module
            KlassProxy.new(callable, method_name, *args, init_args: init_args, init_kwargs: init_kwargs, **kwargs, &block)
          when String
            klass = callable.safe_constantize
            raise ArgumentError, "could not resolve class from: #{callable.inspect}" unless klass

            KlassProxy.new(klass, method_name, *args, init_args: init_args, init_kwargs: init_kwargs, **kwargs, &block)
          end
        end
      end
    end
  end
end
