# frozen_string_literal: true

require_relative "../application_system_test_case"

class TextareaSystemTest < ApplicationSystemTestCase
  def test_renders_textarea
    visit "/form/textarea"

    assert_selector "label", text: %r{Bio}
    assert_selector "textarea"
  end

  def test_renders_hint_text
    visit "/form/textarea"

    assert_text "Tell us about yourself."
  end

  def test_textarea_has_auto_resize_controller
    visit "/form/textarea"

    assert_selector "textarea[data-controller='auto-resize']"
  end

  def test_label_is_associated_with_textarea
    visit "/form/textarea"

    textarea_id = find("textarea")[:id]

    assert_selector "label[for='#{textarea_id}']"
  end

  def test_passes_wcag
    visit "/form/textarea"

    assert_accessible
  end
end
