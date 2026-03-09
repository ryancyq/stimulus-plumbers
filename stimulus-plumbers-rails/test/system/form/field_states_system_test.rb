# frozen_string_literal: true

require_relative "../application_system_test_case"

class FieldStatesSystemTest < ApplicationSystemTestCase
  def test_renders_required_field_with_indicator
    visit "/form/field_states"

    assert_selector "label",                   text: /Full name/
    assert_selector "span[aria-hidden='true']", text: "*"
  end

  def test_renders_hint_text
    visit "/form/field_states"

    assert_text "We'll never share your email."
  end

  def test_renders_error_from_model
    visit "/form/field_states"

    assert_selector "[role='alert']"
  end

  def test_renders_error_override
    visit "/form/field_states"

    assert_text "This field is required."
  end

  def test_renders_visually_hidden_label
    visit "/form/field_states"

    assert_selector ".sr-only", text: /Search query/
  end

  def test_error_field_has_aria_describedby
    visit "/form/field_states"

    error_el = find("[role='alert']", match: :first)
    refute_nil error_el[:id], "Error paragraph must have an id"
  end

  def test_passes_wcag
    visit "/form/field_states"

    assert_accessible
  end
end
