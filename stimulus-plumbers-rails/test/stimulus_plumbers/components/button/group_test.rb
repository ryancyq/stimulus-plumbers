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

  def test_renders_with_alignment_option
    assert_css parse_html(renderer.render(alignment: :right) { "" }), "div[role='group']"
  end

  def test_renders_with_direction_option
    assert_css parse_html(renderer.render(direction: :column) { "" }), "div[role='group']"
  end
end
