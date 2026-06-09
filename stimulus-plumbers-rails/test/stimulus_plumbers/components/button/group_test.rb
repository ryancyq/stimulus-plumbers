# frozen_string_literal: true

require "test_helper"

class ButtonGroupTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Button::Group.new(self)
  end

  def test_renders_div
    doc = parse_html(renderer.render { "button" })

    assert_css doc, "div"
    assert_includes doc.text, "button"
  end

  def test_renders_role_group
    assert_css parse_html(renderer.render { "" }), "div[role='group']"
  end

  def test_merges_custom_class
    assert_css parse_html(renderer.render(class: "custom") { "" }), ".custom"
  end

  def test_passes_html_options
    assert_css parse_html(renderer.render(id: "btn-group") { "" }), "#btn-group"
  end

  def test_renders_with_inline_layout
    assert_css parse_html(renderer.render(layout: :inline) { "" }), "div[role='group']"
  end

  def test_renders_with_stacked_layout
    assert_css parse_html(renderer.render(layout: :stacked) { "" }), "div[role='group']"
  end

  def test_button_renders_inside_group
    doc = parse_html(renderer.render { |group| group.button("Save") })

    assert_css doc, "div[role='group'] button"
    assert_includes doc.text, "Save"
  end

  def test_button_passes_options
    doc = parse_html(renderer.render { |group| group.button("Cancel", variant: :outline) })

    assert_css doc, "div[role='group'] button"
    assert_includes doc.text, "Cancel"
  end

  def test_button_renders_multiple
    doc = parse_html(renderer.render { |group| group.button("A") + group.button("B") })

    assert_equal 2, doc.css("button").length
  end
end
