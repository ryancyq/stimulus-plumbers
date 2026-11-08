# frozen_string_literal: true

require "active_support/core_ext/enumerable"

module StimulusPlumbers
  # Dev/CI-only: the class and module structure of Ruby files, read line by line.
  module RubySource
    class << self
      # Each line's enclosing class and module names, outermost first.
      def nesting_stack(file)
        stack = []
        file.readlines.map do |line|
          update_nesting_stack(stack, line)
          stack.map { |(_, name)| name }
        end
      end

      # Class name => its superclass, the superclass's superclass, and so on, each fully nested.
      def ancestors(root)
        superclasses = superclass_table(root)
        superclasses.keys.index_with { |name| ancestors_of(name, superclasses) }
      end

      private

      def update_nesting_stack(stack, line)
        if (m = line.match(%r{^(\s*)(?:class|module)\s+(\w+)}))
          stack << [m[1].size, m[2]]
        elsif (m = line.match(%r{^(\s*)end\s*$})) && stack.any? && stack.last[0] == m[1].size
          stack.pop
        end
      end

      # Class or module name => its superclass, resolved lexically, or nil.
      def superclass_table(root)
        declared = {}
        root.glob("**/*.rb").each { |file| declare(file, declared) }
        declared.to_h { |name, superclass| [name, superclass && lexical(name.split("::")[0...-1], superclass, declared)] }
      end

      # A class reopened without a superclass keeps the one it was declared with.
      def declare(file, declared)
        stacks = nesting_stack(file)
        file.readlines.each_with_index do |line, idx|
          next unless line.match?(%r{^\s*(?:class|module)\s+\w+})

          name = stacks[idx].join("::")
          superclass = line[%r{^\s*class\s+\w+\s*<\s*([\w:]+)}, 1]
          declared[name] = superclass if superclass || !declared.key?(name)
        end
      end

      def lexical(nesting, name, declared)
        nesting.size.downto(0).map { |i| (nesting.first(i) + [name]).join("::") }.find { |key| declared.key?(key) }
      end

      def ancestors_of(name, superclasses)
        superclass = superclasses[name]
        superclass ? [superclass, *ancestors_of(superclass, superclasses)] : []
      end
    end
  end
end
