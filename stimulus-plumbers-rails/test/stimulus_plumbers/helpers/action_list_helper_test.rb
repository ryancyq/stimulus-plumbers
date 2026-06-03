# frozen_string_literal: true

require "test_helper"

class ActionListHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::ActionListHelper

  def test_renders_container_ul
    assert_css parse_html(sp_action_list { "" }), "ul"
  end

  def test_yields_builder
    doc = parse_html(
      sp_action_list do |list|
        list.section { list.item("Action") }
      end
    )

    assert_css doc, "ul > li > ul > li > button"
    assert_includes doc.text, "Action"
  end

  def test_composition
    doc = parse_html(
      sp_action_list do |list|
        list.section(title: "Nav") { list.item("Home", url: "/") }
      end
    )

    assert_css doc, "ul"
    assert_css doc, "li"
    assert_css doc, "a[href='/']"
    assert_includes doc.text, "Nav"
  end
end
