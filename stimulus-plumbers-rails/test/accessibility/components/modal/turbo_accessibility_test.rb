# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class ModalTurboAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/modal/turbo"
  end

  def test_passes_wcag_with_turbo_modal_closed
    assert_accessible context: "#modal-turbo"
  end

  def test_passes_wcag_with_turbo_modal_open
    click_link "Edit profile"

    assert_selector "#modal-turbo dialog[open]"
    assert_accessible context: "#modal-turbo"
  end

  def test_passes_wcag_after_turbo_validation_error
    click_link "Edit profile"
    click_button "Save"

    assert_selector "#modal-form-error", text: "Name is required"
    assert_field "Name", focused: true
    assert_selector "#modal-form-name[aria-invalid='true'][aria-describedby='modal-form-error']"
    assert_accessible context: "#modal-turbo"
  end
end
