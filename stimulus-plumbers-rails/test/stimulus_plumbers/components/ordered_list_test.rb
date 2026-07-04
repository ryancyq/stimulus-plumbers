# frozen_string_literal: true

require "test_helper"

class OrderedListComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::OrderedList.new(self)
  end

  def test_renders_ol
    assert_css parse_html(renderer.render { "" }), "ol"
  end

  def test_wires_reorderable_controller
    assert_css parse_html(renderer.render { "" }), "ol[data-controller='reorderable']"
  end

  def test_has_list_role
    assert_css parse_html(renderer.render { "" }), "ol[role='list']"
  end

  def test_role_can_be_overridden
    assert_css parse_html(renderer.render(role: "presentation") { "" }), "ol[role='presentation']"
  end

  def test_default_move_key_is_alt
    assert_css parse_html(renderer.render { "" }), "ol[data-reorderable-move-key-value='Alt']"
  end

  def test_move_key_can_be_overridden
    assert_css parse_html(renderer.render(move_key: "Control") { "" }), "ol[data-reorderable-move-key-value='Control']"
  end

  def test_editing_defaults_to_false
    assert_css parse_html(renderer.render { "" }), "ol[data-reorderable-editing-value='false']"
  end

  def test_editing_can_be_enabled
    assert_css parse_html(renderer.render(editing: true) { "" }), "ol[data-reorderable-editing-value='true']"
  end

  def test_orientation_is_unset_by_default
    assert_no_css parse_html(renderer.render { "" }), "ol[data-reorderable-orientation-value]"
  end

  def test_orientation_can_be_set
    doc = parse_html(renderer.render(orientation: "horizontal") { "" })

    assert_css doc, "ol[data-reorderable-orientation-value='horizontal']"
  end

  def test_item_convenience_method_delegates_to_ordered_list_item
    doc = parse_html(renderer.item("Row", id: "row-1"))

    assert_css doc, "li#row-1"
  end

  def test_has_no_section_method
    refute_respond_to renderer, :section
  end
end
