# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class ModalAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/modal"
  end

  def test_confirmation_passes_wcag_closed
    assert_accessible context: "#modal-confirmation"
  end

  def test_no_autofocus_passes_wcag_closed
    assert_accessible context: "#modal-no-autofocus"
  end

  def test_method_dialog_passes_wcag_closed
    assert_accessible context: "#modal-method-dialog"
  end

  def test_closedby_any_passes_wcag_closed
    assert_accessible context: "#modal-closedby-any"
  end

  def test_closedby_closerequest_passes_wcag_closed
    assert_accessible context: "#modal-closedby-closerequest"
  end

  def test_closedby_none_passes_wcag_closed
    assert_accessible context: "#modal-closedby-none"
  end

  def test_aria_label_passes_wcag_closed
    assert_accessible context: "#modal-aria-label"
  end

  def test_body_only_passes_wcag_closed
    assert_accessible context: "#modal-body-only"
  end

  def test_passes_wcag_with_modal_open
    click_button "Delete project"

    assert_selector "#modal-confirmation-dialog[open]"
    assert_accessible context: "#modal-confirmation"
  end

  def test_passes_wcag_with_titleless_modal_open
    click_button "Open project details"

    assert_selector "#modal-aria-label-dialog[open]"
    assert_accessible context: "#modal-aria-label"
  end

  def test_passes_wcag_with_body_only_modal_open
    click_button "Open body-only modal"

    assert_selector "#modal-body-only-dialog[open]"
    assert_accessible context: "#modal-body-only"
  end
end
