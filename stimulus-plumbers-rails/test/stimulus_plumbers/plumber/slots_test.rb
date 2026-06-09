# frozen_string_literal: true

require "test_helper"

class PlumberSlotsTest < ActionView::TestCase
  class TestSlots < StimulusPlumbers::Plumber::Slots
    slot :name, :value
  end

  class SubSlots < StimulusPlumbers::Plumber::Slots
    slot :icon, :title
  end

  class ParentSlots < StimulusPlumbers::Plumber::Slots
    slot :body
    slot :header, by: SubSlots
  end

  # ── slot DSL — simple ─────────────────────────────────────────────────────────

  def test_slot_generated_method_returns_nil_for_value
    assert_nil TestSlots.new.with_name("hello")
  end

  def test_slot_generated_method_returns_nil_for_block
    assert_nil(TestSlots.new.with_name { "hello" })
  end

  def test_slot_generated_method_stores_string_value
    slots = TestSlots.new
    slots.with_name("hello")

    assert_equal "hello", slots.resolve(:name)
  end

  def test_slot_generated_method_stores_block
    slots = TestSlots.new
    slots.with_name { "hello" }

    assert_equal "hello", slots.resolve(:name)
  end

  def test_slot_block_takes_precedence_over_value
    slots = TestSlots.new
    slots.with_name("ignored") { "block wins" }

    assert_equal "block wins", slots.resolve(:name)
  end

  def test_multiple_slots_declared_independently
    slots = TestSlots.new
    slots.with_name("Alice")
    slots.with_value("admin")

    assert_equal "Alice", slots.resolve(:name)
    assert_equal "admin", slots.resolve(:value)
  end

  # ── predicate methods ─────────────────────────────────────────────────────────

  def test_predicate_false_before_setter
    refute_predicate TestSlots.new, :name?
  end

  def test_predicate_true_after_setter
    slots = TestSlots.new
    slots.with_name("hello")

    assert_predicate slots, :name?
  end

  # ── slot DSL — by: (nested builder) ─────────────────────────────────────────

  def test_slot_by_generated_method_returns_nil
    assert_nil(ParentSlots.new.with_header { |h| h.with_icon("check") })
  end

  def test_slot_by_yields_sub_builder
    parent = ParentSlots.new
    parent.with_header do |h|
      h.with_icon("check")
      h.with_title("My Card")
    end

    header = parent.resolve(:header)

    assert_instance_of SubSlots, header
    assert_equal "check",   header.resolve(:icon)
    assert_equal "My Card", header.resolve(:title)
  end

  def test_slot_by_sub_builder_without_block
    parent = ParentSlots.new
    parent.with_header

    header = parent.resolve(:header)

    assert_instance_of SubSlots, header
    refute_predicate header, :any?
  end

  # ── resolve with transform block ─────────────────────────────────────────────

  def test_resolve_yields_value_to_block_when_set
    slots = TestSlots.new
    slots.with_name("check")

    result = slots.resolve(:name) { |v| "icon:#{v}" }

    assert_equal "icon:check", result
  end

  def test_resolve_returns_nil_when_not_set_even_with_block
    slots = TestSlots.new

    assert_nil slots.resolve(:name) { |v| "icon:#{v}" }
  end

  # ── options_for ───────────────────────────────────────────────────────────────

  def test_options_for_returns_empty_hash_when_not_set
    assert_equal({}, TestSlots.new.options_for(:name))
  end

  def test_options_for_returns_stored_options
    slots = TestSlots.new
    slots.with_name("Alice")

    assert_equal({}, slots.options_for(:name))
  end

  # ── any? ─────────────────────────────────────────────────────────────────────

  def test_any_false_before_any_setter
    refute_predicate TestSlots.new, :any?
  end

  def test_any_true_after_setter_call
    slots = TestSlots.new
    slots.with_name("hello")

    assert_predicate slots, :any?
  end
end
