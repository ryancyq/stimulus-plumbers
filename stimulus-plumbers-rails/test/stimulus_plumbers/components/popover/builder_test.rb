# frozen_string_literal: true

require "test_helper"

class PopoverBuilderTest < ActionView::TestCase
  def builder
    StimulusPlumbers::Components::Popover::Builder.new(self)
  end

  def test_activator_html_nil_by_default
    assert_nil builder.activator_html
  end

  def test_content_html_nil_by_default
    assert_nil builder.content_html
  end

  def test_activator_captures_block_output
    b = builder
    b.activator { "Open popover" }

    assert_includes b.activator_html, "Open popover"
  end

  def test_content_captures_block_output
    b = builder
    b.content { "Popover body" }

    assert_includes b.content_html, "Popover body"
  end

  def test_activator_and_content_are_independent
    b = builder
    b.activator { "trigger" }
    b.content   { "body" }

    assert_includes b.activator_html, "trigger"
    assert_includes b.content_html,   "body"
  end
end
