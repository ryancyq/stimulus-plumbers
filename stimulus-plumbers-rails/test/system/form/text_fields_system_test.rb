# frozen_string_literal: true

require_relative "../application_system_test_case"

class TextFieldsSystemTest < ApplicationSystemTestCase
  def test_renders_all_input_types
    visit "/form/text_fields"

    assert_selector "input[type='email']"
    assert_selector "input[type='text']"
    assert_selector "input[type='number']"
    assert_selector "input[type='date']"
  end

  def test_each_input_has_an_associated_label
    visit "/form/text_fields"

    assert_selector "label[for='demo_email']"
    assert_selector "label[for='demo_name']"
    assert_selector "label[for='demo_age']"
    assert_selector "label[for='demo_birth_date']"
  end

  def test_passes_wcag
    visit "/form/text_fields"

    assert_accessible
  end
end
