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

  def test_label_comes_from_the_locale_file
    assert_selector "#code-default label", text: "Security code"
  end
end
