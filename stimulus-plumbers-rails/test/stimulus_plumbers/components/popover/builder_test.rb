# frozen_string_literal: true

require "test_helper"

class PopoverBuilderTest < ActionView::TestCase
  def builder(panel_id: nil)
    StimulusPlumbers::Components::Popover::Builder.new(self, panel_id: panel_id)
  end

  def test_trigger_html_nil_by_default
    assert_nil builder.trigger_html
  end

  def test_panel_html_nil_by_default
    assert_nil builder.panel_html
  end

  def test_panel_id_generated_when_not_provided
    assert_not_nil builder.panel_id
    assert_match(%r{_panel$}, builder.panel_id)
  end

  def test_panel_id_uses_provided_value
    assert_equal "my_panel", builder(panel_id: "my_panel").panel_id
  end

  def test_trigger_zero_arity_block_renders_button_with_content
    b = builder(panel_id: "p1")
    b.trigger { "Open" }

    assert_css parse_html(b.trigger_html), "button"
    assert_includes b.trigger_html, "Open"
  end

  def test_trigger_one_arity_block_yields_attrs
    b       = builder(panel_id: "p1")
    yielded = nil
    b.trigger { |attrs| yielded = attrs }

    assert_equal "p1", yielded[:panel_id]
    assert_equal "dialog", yielded[:aria][:haspopup]
    assert_equal "false", yielded[:aria][:expanded]
    assert_equal "p1", yielded[:aria][:controls]
    assert_includes yielded[:data][:action], "popover#toggle"
  end

  def test_panel_captures_block_output
    b = builder(panel_id: "p1")
    b.panel { "Popover body" }

    assert_includes b.panel_html, "Popover body"
  end

  def test_panel_renders_wired_element
    b = builder(panel_id: "p1")
    b.panel { "body" }

    assert_css parse_html(b.panel_html), "#p1[data-popover-target='panel'][hidden]"
  end

  def test_build_panel_yields_panel_attrs_to_caller
    b             = builder(panel_id: "p1")
    yielded_attrs = nil
    b.build_panel { |attrs| yielded_attrs = attrs }

    assert_equal "p1",    yielded_attrs[:id]
    assert_equal "panel", yielded_attrs.dig(:data, :popover_target)
  end

  def test_trigger_and_panel_are_independent
    b = builder(panel_id: "p1")
    b.trigger { "trigger" }
    b.panel   { "body" }

    assert_includes b.trigger_html, "trigger"
    assert_includes b.panel_html,   "body"
  end
end
