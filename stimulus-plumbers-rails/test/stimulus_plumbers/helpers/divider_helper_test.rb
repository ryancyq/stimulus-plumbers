# frozen_string_literal: true

require "test_helper"

class DividerHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::DividerHelper

  def test_renders_hr_element
    assert_includes sp_divider, "<hr"
  end

  def test_merges_custom_class
    assert_includes sp_divider(class: "separator"), "separator"
  end
end
