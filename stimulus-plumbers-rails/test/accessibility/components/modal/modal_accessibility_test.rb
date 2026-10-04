# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class ModalAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/modal"
  end

  def test_passes_wcag_with_modal_closed
    assert_accessible context: "#modal"
  end

  def test_passes_wcag_with_modal_open
    click_button "Delete project"

    assert_selector "#modal-confirmation[open]"
    assert_accessible context: "#modal"
  end

  def test_optional_regions_pass_wcag_when_open
    assert_accessible context: "#modal-aria-label"
    click_button "Open project details"

    assert_selector "#modal-aria-label-dialog[open]"
    assert_accessible context: "#modal-aria-label"

    click_button "Done"
    click_button "Open body-only modal"

    assert_selector "#modal-body-only-dialog[open]"
    assert_accessible context: "#modal-body-only"
  end
end
