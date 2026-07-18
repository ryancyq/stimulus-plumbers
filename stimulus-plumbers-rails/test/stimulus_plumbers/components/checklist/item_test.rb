# frozen_string_literal: true

require "test_helper"

class ChecklistItemTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Checklist::Item.new(self)
  end

  def test_renders_label_wrapping_a_checkbox_input
    doc = parse_html(renderer.render("Buy milk", checked: true))

    assert_css doc, "label input[type='checkbox']"
  end

  def test_renders_data_checklist_target_item_for_the_checklist_controller
    doc = parse_html(renderer.render("Buy milk", checked: true))

    assert_css doc, "input[data-checklist-target='item']"
  end

  def test_checked_true_sets_the_checked_attribute
    doc = parse_html(renderer.render("Buy milk", checked: true))

    assert_css doc, "input[type='checkbox'][checked]"
  end

  def test_checked_false_omits_the_checked_attribute
    doc = parse_html(renderer.render("Buy milk", checked: false))

    assert_no_css doc, "input[checked]"
  end

  def test_checked_is_a_required_keyword
    err = assert_raises(ArgumentError) { renderer.render("Buy milk") }
    assert_equal "checked: is required", err.message
  end

  def test_readonly_true_sets_disabled
    doc = parse_html(renderer.render("Buy milk", checked: true, readonly: true))

    assert_css doc, "input[type='checkbox'][disabled]"
  end

  def test_readonly_false_omits_disabled
    doc = parse_html(renderer.render("Buy milk", checked: true))

    assert_no_css doc, "input[disabled]"
  end

  def test_renders_title_from_fast_path
    doc = parse_html(renderer.render("Buy milk", checked: true))

    assert_includes doc.text, "Buy milk"
  end

  def test_block_title_overwrites_fast_path
    doc = parse_html(renderer.render("First", checked: true) { |item| item.with_title("Second") })

    assert_includes doc.text, "Second"
    refute_includes doc.text, "First"
  end

  def test_renders_description
    doc = parse_html(renderer.render("Buy milk", checked: true) { |item| item.with_description("2%, whole") })

    assert_includes doc.text, "2%, whole"
  end

  def test_merges_custom_class
    assert_css parse_html(renderer.render("Buy milk", checked: true, class: "custom")), "label.custom"
  end
end
