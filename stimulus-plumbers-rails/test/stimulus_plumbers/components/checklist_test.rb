# frozen_string_literal: true

require "test_helper"

class ChecklistTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Checklist.new(self)
  end

  def test_renders_div_with_group_role
    doc = parse_html(renderer.render { |c| c.item("Buy milk", checked: true) })

    assert_css doc, "div[role='group']"
  end

  def test_renders_items_via_block
    doc = parse_html(renderer.render { |c| c.item("Buy milk", checked: true) })

    assert_includes doc.text, "Buy milk"
  end

  def test_label_sets_aria_label
    doc = parse_html(renderer.render(label: "Groceries") { |c| c.item("Buy milk", checked: true) })

    assert_css doc, "div[aria-label='Groceries']"
  end

  def test_labelledby_sets_aria_labelledby_and_omits_label
    doc = parse_html(renderer.render(labelledby: "heading-id") { |c| c.item("Buy milk", checked: true) })

    assert_css doc, "div[aria-labelledby='heading-id']"
    assert_no_css doc, "div[aria-label]"
  end

  def test_omits_aria_label_and_labelledby_when_neither_given
    doc = parse_html(renderer.render { |c| c.item("Buy milk", checked: true) })

    assert_no_css doc, "div[aria-label]"
    assert_no_css doc, "div[aria-labelledby]"
  end

  def test_merges_custom_class
    doc = parse_html(renderer.render(class: "custom") { |c| c.item("Buy milk", checked: true) })

    assert_css doc, ".custom"
  end

  def test_select_all_false_by_default_leaves_output_unchanged
    doc = parse_html(renderer.render { |c| c.item("Buy milk", checked: true) })

    assert_no_css doc, "input[data-checklist-target='master']"
    assert_no_css doc, "div[data-controller='checklist']"
  end

  def test_select_all_renders_master_input
    doc = parse_html(renderer.render(select_all: true) { |c| c.item("Buy milk", checked: true) })

    assert_css doc, "label input[type='checkbox'][data-checklist-target='master']"
  end

  def test_select_all_wraps_wrapper_with_checklist_controller
    doc = parse_html(renderer.render(select_all: true) { |c| c.item("Buy milk", checked: true) })

    div = doc.at_css("div[role='group']")

    assert_equal "checklist", div["data-controller"]
    assert_equal "change->checklist#onChange", div["data-action"]
  end

  def test_select_all_label_customizes_input_accessible_text
    doc = parse_html(
      renderer.render(select_all: true, select_all_label: "Toggle all") { |c| c.item("Buy milk", checked: true) }
    )

    assert_includes doc.text, "Toggle all"
  end

  def test_select_all_checked_when_all_items_checked
    doc = parse_html(
      renderer.render(select_all: true) do |c|
        c.item("Buy milk", checked: true)
        c.item("Buy eggs", checked: true)
      end
    )

    assert_css doc, "input[data-checklist-target='master'][checked]"
  end

  def test_select_all_unchecked_when_all_items_unchecked
    doc = parse_html(
      renderer.render(select_all: true) do |c|
        c.item("Buy milk", checked: false)
        c.item("Buy eggs", checked: false)
      end
    )

    assert_no_css doc, "input[data-checklist-target='master'][checked]"
  end

  def test_select_all_unchecked_when_items_are_mixed
    doc = parse_html(
      renderer.render(select_all: true) do |c|
        c.item("Buy milk", checked: true)
        c.item("Buy eggs", checked: false)
      end
    )

    assert_no_css doc, "input[data-checklist-target='master'][checked]"
  end

  def test_select_all_unchecked_when_zero_items
    doc = parse_html(renderer.render(select_all: true) { nil })

    assert_no_css doc, "input[data-checklist-target='master'][checked]"
  end

  def test_select_all_excludes_readonly_items_from_aggregate
    doc = parse_html(
      renderer.render(select_all: true) do |c|
        c.item("Buy milk", checked: false)
        c.item("Locked item", checked: true, readonly: true)
      end
    )

    assert_no_css doc, "input[data-checklist-target='master'][checked]"
  end
end
