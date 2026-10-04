# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class ModalFormAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/modal/form"
  end

  def test_direct_modal_form_route_passes_wcag
    assert_accessible context: "#modal-form"
  end
end
