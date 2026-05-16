# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class FieldErrorAccessibilityTest < ApplicationAccessibilityTestCase
  def test_renders_required_field_with_indicator
    visit "/a11y/form/field_error"

    assert_selector "label", text: %r{Full name}
    assert_selector "span[aria-hidden='true']", text: "*"
  end

  def test_renders_error_from_model
    visit "/a11y/form/field_error"

    assert_selector "[role='alert']"
  end

  def test_renders_error_override
    visit "/a11y/form/field_error"

    assert_text "This field is required."
  end

  def test_renders_visually_hidden_label
    visit "/a11y/form/field_error"

    assert_selector "label", text: %r{Search query}, visible: :all
  end

  def test_error_field_has_aria_describedby
    visit "/a11y/form/field_error"

    error_el = find("[role='alert']", match: :first)

    refute_nil error_el[:id], "Error paragraph must have an id"
  end

  def test_passes_wcag
    visit "/a11y/form/field_error"

    assert_accessible
  end
end
