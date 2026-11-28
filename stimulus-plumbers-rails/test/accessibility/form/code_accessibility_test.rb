# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class CodeAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/code"
  end

  def test_default_passes_wcag
    assert_accessible context: "#code-default"
  end

  def test_arrow_keys_move_the_caret_cell
    within "#code-default" do
      find_field("Verification code").send_keys "482913", :left, :left

      assert_css "[data-input-code-target='cell'][data-caret]", count: 1
      assert_css "[data-input-code-target='cell']:nth-child(5)[data-caret]"
    end
  end
end
