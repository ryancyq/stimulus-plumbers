# frozen_string_literal: true

require "test_helper"

class PlumberRendererTest < Minitest::Test
  class StringDispatchBadgeRenderer
    def initialize(tmpl); end

    def badge
      "gold"
    end
  end

  def template
    Object.new
  end

  def fresh_class
    Class.new(StimulusPlumbers::Plumber::Base)
  end

  def template_capturing_renderer(&on_init)
    Class.new do
      define_method(:initialize, &on_init)

      def render; end
    end
  end

  def test_raises_if_method_name_not_symbol
    assert_raises(ArgumentError) { fresh_class.renders("greeting", with: :build_greeting) }
  end

  def test_raises_if_both_with_and_block_given
    assert_raises(ArgumentError) { fresh_class.renders(:greeting, with: :build_greeting) { nil } }
  end

  def test_raises_if_with_is_invalid_type
    assert_raises(ArgumentError) { fresh_class.renders(:greeting, with: 123) }
  end

  def test_raises_if_neither_with_nor_block
    assert_raises(ArgumentError) { fresh_class.renders(:greeting) }
  end

  def test_renders_with_symbol_delegates_to_named_method
    klass = fresh_class
    klass.renders(:greeting, with: :build_greeting)
    klass.define_method(:build_greeting) { "hello" }

    assert_equal "hello", klass.new(template).greeting
  end

  def test_renders_with_block_executes_in_instance_context
    klass = fresh_class
    klass.define_method(:salutation) { "hello" }
    klass.renders(:greeting) { salutation }

    assert_equal "hello", klass.new(template).greeting
  end

  def test_renders_with_proc_executes_in_instance_context
    klass = fresh_class
    klass.define_method(:salutation) { "hello" }
    klass.renders(:greeting, with: proc { salutation })

    assert_equal "hello", klass.new(template).greeting
  end

  def test_renders_with_class_instantiates_and_calls_method
    badge_renderer = Class.new do
      def initialize(tmpl); end

      def badge
        "gold"
      end
    end
    klass = fresh_class
    klass.renders(:badge, with: badge_renderer)

    assert_equal "gold", klass.new(template).badge
  end

  def test_renders_with_class_passes_template_as_init_arg
    tmpl = Object.new
    captured_template = nil
    klass = fresh_class
    klass.renders(:render, with: template_capturing_renderer { |t| captured_template = t })
    klass.new(tmpl).render

    assert_equal tmpl, captured_template
  end

  def test_renders_with_string_resolves_class_and_calls_method
    klass = fresh_class
    klass.renders(:badge, with: "PlumberRendererTest::StringDispatchBadgeRenderer")

    assert_equal "gold", klass.new(template).badge
  end

  def test_renders_forwards_args
    klass = fresh_class
    klass.renders(:full_name) { |first, last| "#{first} #{last}" }

    assert_equal "Alice Bob", klass.new(template).full_name("Alice", "Bob")
  end

  def test_renders_forwards_kwargs
    klass = fresh_class
    klass.renders(:greeting) { |name:| "Hello, #{name}!" }

    assert_equal "Hello, World!", klass.new(template).greeting(name: "World")
  end

  def test_renders_forwards_args_and_kwargs_to_class
    item_renderer = Class.new do
      def initialize(tmpl); end

      def item(label, style:)
        "#{label}[#{style}]"
      end
    end
    klass = fresh_class
    klass.renders(:item, with: item_renderer)

    assert_equal "card[bold]", klass.new(template).item("card", style: "bold")
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

  def test_renders_proc_does_not_receive_caller_block
    klass = fresh_class
    klass.renders(:badge, with: proc { "gold" })

    result = klass.new(template).badge { raise "caller block should not reach proc" }

    assert_equal "gold", result
  end
end
