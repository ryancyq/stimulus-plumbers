# frozen_string_literal: true

require "test_helper"

class CardSlotsTest < ActionView::TestCase
  def slots
    StimulusPlumbers::Components::Card::Slots.new
  end

  def test_slot_setters_return_nil
    s = slots

    assert_nil s.with_title("Account")
    assert_nil s.with_icon("user")
    assert_nil(s.with_body { "content" })
    assert_nil s.with_action("Go", url: "/")
  end

  def test_action_raises_when_url_given_without_content
    assert_raises(ArgumentError) { slots.with_action(url: "/settings") }
  end

  def test_action_accepts_string_with_url
    assert_nil slots.with_action("Go", url: "/settings")
  end

  def test_action_accepts_block_with_url
    assert_nil slots.with_action(url: "/settings") { "Go" }
  end

  def test_action_no_op_when_called_with_no_arguments
    s = slots

    assert_nil s.with_action
    assert_nil s.resolve(:action)
  end

  def test_action_stores_url_in_options
    s = slots
    s.with_action("Go", url: "/settings")

    assert_equal "/settings", s.options_for(:action)[:url]
  end
end
