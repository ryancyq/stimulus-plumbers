# frozen_string_literal: true

require "test_helper"

module StimulusPlumbers
  module Components
    module Plumber
      class DispatcherTest < Minitest::Test
        class Target
          def no_args
            "no_args"
          end

          def with_args(arg_a, arg_b)
            "#{arg_a}+#{arg_b}"
          end

          def with_variadic(*args)
            args.join(",")
          end

          def with_kwargs(arg_a:, arg_b: "default")
            "#{arg_a}-#{arg_b}"
          end

          def with_all(arg_x, arg_y:)
            "#{arg_x}|#{arg_y}"
          end

          def extra_args_ignored(arg)
            arg
          end

          private

          def private_method
            "private"
          end
        end

        class FakeRenderer
          attr_reader :template, :extra

          def initialize(template, extra: nil)
            @template = template
            @extra = extra
          end

          def render_item(label)
            "rendered:#{label}"
          end

          def render_with_options(label, style:)
            "#{label}[#{style}]"
          end
        end

        class MethodCallTest < DispatcherTest
          def target
            Target.new
          end

          def test_calls_no_arg_method
            assert_equal "no_args", Dispatcher::MethodCall.new(:no_args).call(target)
          end

          def test_calls_method_with_args
            assert_equal "a+b", Dispatcher::MethodCall.new(:with_args, "a", "b").call(target)
          end

          def test_calls_variadic_method
            assert_equal "x,y,z", Dispatcher::MethodCall.new(:with_variadic, "x", "y", "z").call(target)
          end

          def test_filters_extra_args_by_arity
            assert_equal "kept", Dispatcher::MethodCall.new(:extra_args_ignored, "kept", "dropped").call(target)
          end

          def test_forwards_kwargs_when_method_accepts_them
            assert_equal "hello-default", Dispatcher::MethodCall.new(:with_kwargs, arg_a: "hello").call(target)
          end

          def test_does_not_forward_kwargs_when_method_does_not_accept_them
            assert_equal "no_args", Dispatcher::MethodCall.new(:no_args, foo: "bar").call(target)
          end

          def test_forwards_mixed_args_and_kwargs
            assert_equal "pos|kw", Dispatcher::MethodCall.new(:with_all, "pos", arg_y: "kw").call(target)
          end

          def test_calls_private_method
            assert_equal "private", Dispatcher::MethodCall.new(:private_method).call(target)
          end

          def test_raises_for_missing_method
            assert_raises(NotImplementedError) { Dispatcher::MethodCall.new(:nonexistent).call(target) }
          end

          def test_raises_for_invalid_method_name
            assert_raises(ArgumentError) { Dispatcher::MethodCall.new(123) }
          end
        end

        class InstanceExecTest < DispatcherTest
          class Context
            def greeting
              "hello"
            end
          end

          def target
            Context.new
          end

          def test_executes_block_in_target_context
            assert_equal "hello", Dispatcher::InstanceExec.new(proc { greeting }).call(target)
          end

          def test_passes_args_to_block
            assert_equal "x+y", Dispatcher::InstanceExec.new(proc { |a, b| "#{a}+#{b}" }, "x", "y").call(target)
          end

          def test_filters_extra_args_by_arity
            assert_equal "kept", Dispatcher::InstanceExec.new(proc { |a| a }, "kept", "dropped").call(target)
          end

          def test_passes_variadic_args
            assert_equal "a,b,c", Dispatcher::InstanceExec.new(proc { |*args| args.join(",") }, "a", "b", "c").call(target)
          end

          def test_forwards_kwargs_when_block_accepts_them
            assert_equal "item:foo",
                         Dispatcher::InstanceExec.new(
                           proc { |label:|
                             "item:#{label}"
                           },
                           label: "foo"
                         ).call(target)
          end

          def test_does_not_forward_kwargs_when_block_does_not_accept_them
            assert_equal "plain", Dispatcher::InstanceExec.new(proc { "plain" }, foo: "bar").call(target)
          end

          def test_raises_for_non_proc
            assert_raises(ArgumentError) { Dispatcher::InstanceExec.new("not a proc") }
          end
        end

        class KlassProxyTest < DispatcherTest
          def target
            Object.new
          end

          def test_instantiates_klass_with_init_args_and_calls_method
            proxy = Dispatcher::KlassProxy.new(FakeRenderer, :render_item, "hello", init_args: ["tmpl"])

            assert_equal "rendered:hello", proxy.call(target)
          end

          def test_passes_init_kwargs_to_klass_new
            proxy = Dispatcher::KlassProxy.new(
              FakeRenderer,
              :render_item,
              "hello",
              init_args:   ["tmpl"],
              init_kwargs: { extra: "opt" }
            )

            assert_equal "rendered:hello", proxy.call(target)
          end

          def test_passes_method_kwargs
            proxy = Dispatcher::KlassProxy.new(
              FakeRenderer,
              :render_with_options,
              "card",
              init_args: ["tmpl"],
              style:     "bold"
            )

            assert_equal "card[bold]", proxy.call(target)
          end

          def test_raises_for_invalid_klass
            assert_raises(ArgumentError) { Dispatcher::KlassProxy.new("not a class", :render_item) }
          end

          def test_raises_for_invalid_method_name
            assert_raises(ArgumentError) { Dispatcher::KlassProxy.new(FakeRenderer, 123) }
          end
        end

        class BuildTest < DispatcherTest
          def test_returns_method_call_for_symbol
            assert_instance_of Dispatcher::MethodCall, Dispatcher.build(:some_method)
          end

          def test_returns_instance_exec_for_proc
            assert_instance_of Dispatcher::InstanceExec, Dispatcher.build(proc { "x" })
          end

          def test_returns_klass_proxy_for_module
            assert_instance_of Dispatcher::KlassProxy,
                               Dispatcher.build(FakeRenderer, method_name: :render_item, init_args: ["tmpl"])
          end

          def test_returns_klass_proxy_for_string
            result = Dispatcher.build(
              "StimulusPlumbers::Components::Plumber::DispatcherTest::FakeRenderer",
              method_name: :render_item,
              init_args:   ["tmpl"]
            )

            assert_instance_of Dispatcher::KlassProxy, result
            assert_equal FakeRenderer, result.klass
          end

          def test_raises_for_unresolvable_string
            assert_raises(ArgumentError) { Dispatcher.build("NonExistent::ClassName", method_name: :foo) }
          end

          def test_returns_nil_for_unknown_callable
            assert_nil Dispatcher.build(42)
          end

          def test_threads_args_to_method_call
            assert_equal %w[a b], Dispatcher.build(:some_method, "a", "b").args
          end

          def test_threads_kwargs_to_method_call
            assert_equal({ foo: "bar" }, Dispatcher.build(:some_method, foo: "bar").kwargs)
          end

          def test_threads_init_args_and_init_kwargs_to_klass_proxy
            result = Dispatcher.build(
              FakeRenderer,
              method_name: :render_item,
              init_args:   ["tmpl"],
              init_kwargs: { extra: "x" }
            )

            assert_equal ["tmpl"], result.init_args
            assert_equal({ extra: "x" }, result.init_kwargs)
          end
        end
      end
    end
  end
end
