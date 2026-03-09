# frozen_string_literal: true

require_relative "../application_system_test_case"

class ChoiceFieldsSystemTest < ApplicationSystemTestCase
  def test_renders_checkbox
    visit "/form/choice_fields"

    assert_selector "label",                text: /Subscribe to newsletter/
    assert_selector "input[type='checkbox']"
  end

  def test_renders_radio_buttons
    visit "/form/choice_fields"

    assert_selector "label",               text: /Male/
    assert_selector "label",               text: /Female/
    assert_selector "label",               text: /Other/
    assert_selector "input[type='radio']", count: 3
  end

  def test_checkbox_is_associated_with_label
    visit "/form/choice_fields"

    checkbox_id = find("input[type='checkbox']")[:id]
    assert_selector "label[for='#{checkbox_id}']"
  end

  def test_radio_buttons_are_associated_with_labels
    visit "/form/choice_fields"

    all("input[type='radio']").each do |radio|
      assert_selector "label[for='#{radio[:id]}']"
    end
  end

  def test_passes_wcag
    visit "/form/choice_fields"

    assert_accessible
  end
end
