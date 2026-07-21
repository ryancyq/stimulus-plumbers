# frozen_string_literal: true

module StimulusPlumbers
  module Plumber
    module Dispatcher
      module CallableInspector
        private

        def args_for(callable)
          callable.arity.negative? ? args : args.take(callable.arity)
        end

        def accepts_kwargs?(callable)
          callable.parameters.any? { |type, _| %i[key keyreq keyrest].include?(type) }
        end

        def accepts_block?(callable)
          callable.parameters.any? { |type, _| type == :block }
        end
      end
    end
  end
end
