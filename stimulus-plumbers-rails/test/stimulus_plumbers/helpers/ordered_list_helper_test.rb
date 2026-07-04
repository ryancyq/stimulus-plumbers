# frozen_string_literal: true

require "test_helper"

class OrderedListHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::OrderedListHelper

  def test_sp_ordered_list_renders_ol_with_items
    doc = parse_html(sp_ordered_list { |list| list.item("Row", id: "row-1") })

    assert_css doc, "ol[data-controller='reorderable']"
    assert_css doc, "li#row-1"
  end
end
