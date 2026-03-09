# frozen_string_literal: true

require_relative "../application_system_test_case"

class SelectFieldSystemTest < ApplicationSystemTestCase
  def test_renders_select
    visit "/form/select_field"

    assert_selector "label", text: %r{Country}
    assert_selector "select"
  end

  def test_renders_hint_text
    visit "/form/select_field"

    assert_text "Select your country of residence."
  end

  def test_renders_country_options
    visit "/form/select_field"

    assert_selector "option", text: "Australia"
    assert_selector "option", text: "New Zealand"
    assert_selector "option", text: "Singapore"
    assert_selector "option", text: "United States"
  end

  def test_label_is_associated_with_select
    visit "/form/select_field"

    select_id = find("select")[:id]

    assert_selector "label[for='#{select_id}']"
  end

  def test_passes_wcag
    visit "/form/select_field"

    assert_accessible
  end
end
