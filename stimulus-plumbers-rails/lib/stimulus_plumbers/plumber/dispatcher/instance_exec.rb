# frozen_string_literal: true

module StimulusPlumbers
  module Plumber
    module Dispatcher
      class InstanceExec
        include CallableInspector

        attr_reader :block, :args, :kwargs

        def initialize(block, *args, **kwargs)
          @block  = block
          @args   = args
          @kwargs = kwargs
          validate!
        end

        def call(target)
          dispatched = args_for(block)
          if accepts_kwargs?(block)
            target.instance_exec(*dispatched, **kwargs, &block)
          else
            target.instance_exec(*dispatched, &block)
          end
        end

        private

        def validate!
          raise ArgumentError, "invalid block: #{block.inspect}" unless block.is_a?(Proc)
        end
      end
    end
  end
end
