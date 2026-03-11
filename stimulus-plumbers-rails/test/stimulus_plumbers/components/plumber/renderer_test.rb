# frozen_string_literal: true

require "test_helper"

module StimulusPlumbers
  module Components
    module Plumber
      class RendererTest < Minitest::Test
        def template
          Object.new
        end

        def fresh_class
          Class.new(Base)
        end

        def capturing_renderer(&capture)
          Class.new do
            define_method(:initialize, &capture)

            def r_tmpl
              "ok"
            end
          end
        end

        def test_raises_if_method_name_not_symbol
          assert_raises(ArgumentError) { fresh_class.renders("foo", with: :bar) }
        end

        def test_raises_if_both_with_and_block_given
          assert_raises(ArgumentError) { fresh_class.renders(:foo, with: :bar) { nil } }
        end

        def test_raises_if_with_is_invalid_type
          assert_raises(ArgumentError) { fresh_class.renders(:foo, with: 123) }
        end

        def test_raises_if_neither_with_nor_block
          assert_raises(ArgumentError) { fresh_class.renders(:foo) }
        end

        def test_renders_with_symbol_delegates_to_named_method
          klass = fresh_class
          klass.renders(:r_symbol, with: :_build)
          klass.define_method(:_build) { "from_method" }

          assert_equal "from_method", klass.new(template).r_symbol
        end

        def test_renders_with_block_executes_in_instance_context
          klass = fresh_class
          klass.define_method(:label) { "ctx_label" }
          klass.renders(:r_block) { label }

          assert_equal "ctx_label", klass.new(template).r_block
        end

        def test_renders_with_proc_executes_in_instance_context
          klass = fresh_class
          klass.define_method(:label) { "ctx_label" }
          klass.renders(:r_proc, with: proc { label })

          assert_equal "ctx_label", klass.new(template).r_proc
        end

        def test_renders_with_class_instantiates_and_calls_method
          renderer_klass = Class.new do
            def initialize(tmpl); end

            def r_klass
              "class_result"
            end
          end
          klass = fresh_class
          klass.renders(:r_klass, with: renderer_klass)

          assert_equal "class_result", klass.new(template).r_klass
        end

        def test_renders_with_class_passes_template_as_init_arg
          tmpl = Object.new
          captured = nil
          klass = fresh_class
          klass.renders(:r_tmpl, with: capturing_renderer { |t| captured = t })
          klass.new(tmpl).r_tmpl

          assert_equal tmpl, captured
        end

        def test_renders_forwards_args
          klass = fresh_class
          klass.renders(:r_args) { |a, b| "#{a}+#{b}" }

          assert_equal "x+y", klass.new(template).r_args("x", "y")
        end

        def test_renders_forwards_kwargs
          klass = fresh_class
          klass.renders(:r_kwargs) { |label:| "item:#{label}" }

          assert_equal "item:foo", klass.new(template).r_kwargs(label: "foo")
        end

        def test_renders_forwards_args_and_kwargs_to_class
          renderer_klass = Class.new do
            def initialize(tmpl); end

            def r_mixed(label, style:)
              "#{label}[#{style}]"
            end
          end
          klass = fresh_class
          klass.renders(:r_mixed, with: renderer_klass)

          assert_equal "card[bold]", klass.new(template).r_mixed("card", style: "bold")
        end

        def test_renderers_are_isolated_between_sibling_classes
          klass_a = fresh_class
          klass_b = fresh_class
          klass_a.renders(:icon, with: :build_a)
          klass_b.renders(:icon, with: :build_b)

          assert_equal :build_a, klass_a.renderers[:icon]
          assert_equal :build_b, klass_b.renderers[:icon]
        end

        def test_subclass_renders_does_not_mutate_parent
          parent = fresh_class
          parent.renders(:icon, with: :parent_icon)

          child = Class.new(parent)
          child.renders(:icon, with: :child_icon)

          assert_equal :parent_icon, parent.renderers[:icon]
          assert_equal :child_icon, child.renderers[:icon]
        end

        def test_multiple_renders_on_same_class_accumulate
          klass = fresh_class
          klass.renders(:wrapper, with: :build_wrapper)
          klass.renders(:icon, with: :build_icon)

          assert_equal :build_wrapper, klass.renderers[:wrapper]
          assert_equal :build_icon, klass.renderers[:icon]
        end

        def test_renders_with_string_constantizes_and_instantiates
          renderer_klass = Class.new do
            def initialize(tmpl); end

            def r_string
              "string_result"
            end
          end
          stub_const = renderer_klass
          klass = fresh_class
          klass.renders(:r_string, with: stub_const)

          assert_equal "string_result", klass.new(template).r_string
        end
      end
    end
  end
end
