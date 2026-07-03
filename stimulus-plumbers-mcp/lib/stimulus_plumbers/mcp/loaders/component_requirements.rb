# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class ComponentRequirements
      class << self
        def call
          Components.constants
                    .map { |c| Components.const_get(c) }
                    .grep(Class)
                    .to_h { |klass| [component_key(klass), controllers_for(klass).uniq] }
        end

        private

        # Controllers from a component class plus its nested sub-components (e.g. Combobox::Date),
        # keyed to the top-level component. Skips references to sibling components.
        def controllers_for(mod)
          mod.constants(false).flat_map do |const|
            value = mod.const_get(const)
            if const.to_s.end_with?("CONTROLLER")
              Array(value).grep(String).flat_map(&:split)
            elsif nested?(mod, value)
              controllers_for(value)
            else
              []
            end
          end
        end

        def nested?(mod, value)
          value.is_a?(Module) && !value.name.nil? && value.name.start_with?("#{mod.name}::")
        end

        def component_key(klass)
          klass.name.demodulize.underscore.to_sym
        end
      end
    end
  end
end
