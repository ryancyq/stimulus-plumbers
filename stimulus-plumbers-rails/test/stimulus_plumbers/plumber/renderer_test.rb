# frozen_string_literal: true

require "test_helper"

class PlumberRendererTest < Minitest::Test
  def template
    Object.new
  end

  def fresh_class
    Class.new(StimulusPlumbers::Plumber::Base)
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

  def test_raises_if_slots_given_without_with
    assert_raises(ArgumentError) { fresh_class.renders(:greeting, slots: %i[icon title]) }
  end

  def test_raises_if_by_given_without_with
    assert_raises(ArgumentError) { fresh_class.renders(:greeting, by: Class.new(StimulusPlumbers::Plumber::Slots)) }
  end

  def test_raises_if_slots_and_by_both_given
    by_klass = Class.new(StimulusPlumbers::Plumber::Slots)
    assert_raises(ArgumentError) { fresh_class.renders(:greeting, with: :build_greeting, slots: %i[a], by: by_klass) }
  end

  def test_raises_if_by_is_not_a_class
    assert_raises(ArgumentError) { fresh_class.renders(:greeting, with: :build_greeting, by: :not_a_class) }
  end

  def test_renderers_registry_stores_hash_entry
    klass = fresh_class
    klass.renders(:greeting, with: :build_greeting)

    entry = klass.renderers[:greeting]

    assert_equal :build_greeting, entry[:with]
    assert_nil entry[:slots]
    assert_nil entry[:by]
  end

  def test_renderers_registry_promotes_slots_to_anonymous_by
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])

    entry = klass.renderers[:header]

    assert_equal :build_header, entry[:with]
    assert_operator entry[:by], :<, StimulusPlumbers::Plumber::Slots
    assert_respond_to entry[:by].new, :icon
    assert_respond_to entry[:by].new, :title
  end

  def test_renderers_registry_stores_by_when_provided
    by_klass = Class.new(StimulusPlumbers::Plumber::Slots)
    klass = fresh_class
    klass.renders(:card, with: :build_card, by: by_klass)

    entry = klass.renderers[:card]

    assert_equal :build_card, entry[:with]
    assert_equal by_klass, entry[:by]
  end

  def test_renderers_are_isolated_between_sibling_classes
    klass_a = fresh_class
    klass_b = fresh_class
    klass_a.renders(:icon, with: :build_a)
    klass_b.renders(:icon, with: :build_b)

    assert_equal :build_a, klass_a.renderers[:icon][:with]
    assert_equal :build_b, klass_b.renderers[:icon][:with]
  end

  def test_subclass_renders_does_not_mutate_parent
    parent = fresh_class
    parent.renders(:icon, with: :parent_icon)

    child = Class.new(parent)
    child.renders(:icon, with: :child_icon)

    assert_equal :parent_icon, parent.renderers[:icon][:with]
    assert_equal :child_icon, child.renderers[:icon][:with]
  end

  def test_multiple_renders_on_same_class_accumulate
    klass = fresh_class
    klass.renders(:wrapper, with: :build_wrapper)
    klass.renders(:icon, with: :build_icon)

    assert_equal :build_wrapper, klass.renderers[:wrapper][:with]
    assert_equal :build_icon, klass.renderers[:icon][:with]
  end

  def test_value_setter_is_generated
    klass = fresh_class
    klass.renders(:body, with: :build_body)
    instance = klass.new(template)

    assert_respond_to instance, :with_body
  end

  def test_value_setter_stores_value_and_returns_nil
    klass = fresh_class
    klass.renders(:body, with: :build_body)
    klass.define_method(:build_body) { |value:| value }
    instance = klass.new(template)

    assert_nil instance.with_body("hello")
  end

  def test_value_setter_stores_block
    klass = fresh_class
    klass.renders(:body, with: :build_body)
    klass.define_method(:build_body) { |value:| value.call }
    instance = klass.new(template)

    assert_nil(instance.with_body { "block" })
  end

  def test_slot_setter_is_generated
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])
    instance = klass.new(template)

    assert_respond_to instance, :with_header
  end

  def test_slot_getter_is_generated
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])
    instance = klass.new(template)

    assert_respond_to instance, :header
  end

  def test_slot_predicate_is_generated
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])
    instance = klass.new(template)

    assert_respond_to instance, :header?
  end

  def test_slot_getter_returns_nil_before_setter_called
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])
    instance = klass.new(template)

    assert_nil instance.header
  end

  def test_slot_predicate_returns_false_before_setter_called
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])
    instance = klass.new(template)

    refute_predicate instance, :header?
  end

  def test_slot_getter_returns_slots_builder_after_setter_called
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])
    klass.define_method(:build_header) { |**| nil }
    instance = klass.new(template)
    instance.with_header { |s| s.with_icon("check") }

    assert_instance_of klass.renderers[:header][:by], instance.header
  end

  def test_slot_predicate_returns_true_after_setter_called
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])
    klass.define_method(:build_header) { |**| nil }
    instance = klass.new(template)
    instance.with_header { |s| s.with_icon("check") }

    assert_predicate instance, :header?
  end

  def test_slot_predicate_returns_false_for_empty_slots_builder
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])
    klass.define_method(:build_header) { |**| nil }
    instance = klass.new(template)
    instance.with_header { |s| s }

    refute_predicate instance, :header?
  end

  def test_slot_setter_returns_nil
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])
    klass.define_method(:build_header) { |**| nil }
    instance = klass.new(template)

    assert_nil(instance.with_header { |s| s.with_icon("user") })
  end

  def test_slot_setter_passes_slots_instance_to_builder
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])
    captured = nil
    klass.define_method(:build_header) do |slot:|
      captured = slot
      nil
    end
    instance = klass.new(template)
    instance.with_header { |s| s.with_icon("user") }
    instance.render_header

    assert_instance_of klass.renderers[:header][:by], captured
  end

  def test_slot_setter_resolves_slot_values
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])
    captured = nil
    klass.define_method(:build_header) do |slot:|
      captured = slot
      nil
    end
    instance = klass.new(template)

    instance.with_header do |s|
      s.with_icon("user")
      s.with_title("Profile")
    end
    instance.render_header

    assert_equal "user",    captured.resolve(:icon)
    assert_equal "Profile", captured.resolve(:title)
  end

  def test_render_method_is_generated
    klass = fresh_class
    klass.renders(:greeting, with: :build_greeting)
    instance = klass.new(template)

    assert_respond_to instance, :render_greeting
  end

  def test_render_method_returns_nil_when_nothing_stored
    klass = fresh_class
    klass.renders(:greeting, with: :build_greeting)
    instance = klass.new(template)

    assert_nil instance.render_greeting
  end

  def test_render_with_symbol_delegates_to_named_method
    klass = fresh_class
    klass.renders(:greeting, with: :build_greeting)
    klass.define_method(:build_greeting) { |value:| value }
    instance = klass.new(template)
    instance.with_greeting("hello")

    assert_equal "hello", instance.render_greeting
  end

  def test_render_with_symbol_and_slots
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])
    klass.define_method(:build_header) { |slot:| "#{slot.resolve(:icon)}:#{slot.resolve(:title)}" }
    instance = klass.new(template)
    instance.with_header do |s|
      s.with_icon("user")
      s.with_title("Profile")
    end

    assert_equal "user:Profile", instance.render_header
  end

  def test_render_with_slots_returns_nil_when_no_sub_slot_set
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])
    klass.define_method(:build_header) { |**| "should not reach" }
    instance = klass.new(template)
    instance.with_header { |s| s }

    assert_nil instance.render_header
  end

  def test_render_with_slots_returns_nil_when_setter_not_called
    klass = fresh_class
    klass.renders(:header, with: :build_header, slots: %i[icon title])
    klass.define_method(:build_header) { |**| "should not reach" }
    instance = klass.new(template)

    assert_nil instance.render_header
  end

  def test_by_setter_is_generated
    by_klass = Class.new(StimulusPlumbers::Plumber::Slots)
    klass = fresh_class
    klass.renders(:card, with: :build_card, by: by_klass)

    assert_respond_to klass.new(template), :with_card
  end

  def test_by_setter_returns_nil
    by_klass = Class.new(StimulusPlumbers::Plumber::Slots)
    klass = fresh_class
    klass.renders(:card, with: :build_card, by: by_klass)

    assert_nil klass.new(template).with_card
  end

  def test_by_setter_stores_slots_instance
    by_klass = Class.new(StimulusPlumbers::Plumber::Slots) { slot :title }
    klass = fresh_class
    captured = nil
    klass.renders(:card, with: :build_card, by: by_klass)
    klass.define_method(:build_card) do |slot:|
      captured = slot
      nil
    end
    instance = klass.new(template)

    instance.with_card { |s| s.with_title("Hello") }
    instance.render_card

    assert_instance_of by_klass, captured
    assert_equal "Hello", captured.resolve(:title)
  end

  def test_by_render_passes_slot_object_as_slot_kwarg
    by_klass = Class.new(StimulusPlumbers::Plumber::Slots) { slot :icon, :title }
    klass = fresh_class
    klass.renders(:card, with: :build_card, by: by_klass)
    klass.define_method(:build_card) { |slot:| "#{slot.resolve(:icon)}:#{slot.resolve(:title)}" }
    instance = klass.new(template)

    instance.with_card do |s|
      s.with_icon("user")
      s.with_title("Profile")
    end

    assert_equal "user:Profile", instance.render_card
  end

  def test_by_render_returns_nil_when_slot_empty
    by_klass = Class.new(StimulusPlumbers::Plumber::Slots)
    klass = fresh_class
    klass.renders(:card, with: :build_card, by: by_klass)
    klass.define_method(:build_card) { |**| "should not reach" }
    instance = klass.new(template)
    instance.with_card

    assert_nil instance.render_card
  end

  def test_by_render_returns_nil_when_setter_not_called
    by_klass = Class.new(StimulusPlumbers::Plumber::Slots)
    klass = fresh_class
    klass.renders(:card, with: :build_card, by: by_klass)
    klass.define_method(:build_card) { |**| "should not reach" }

    assert_nil klass.new(template).render_card
  end
end
