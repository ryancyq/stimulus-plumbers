# frozen_string_literal: true

require_relative "../application_system_test_case"

class PasswordFieldSystemTest < ApplicationSystemTestCase
  def test_renders_password_input
    visit "/form/password_field"

    assert_selector "label", text: %r{Password}
    assert_selector "input[type='password']"
  end

  def test_renders_required_indicator
    visit "/form/password_field"

    assert_selector "span[aria-hidden='true']", text: "*"
  end

  def test_password_reveal_toggle
    visit "/form/password_field"

    assert_selector "[data-controller='password-reveal']"
    find("button[data-action='click->password-reveal#toggle']").click

    assert_selector "input[type='text']"

    find("button[data-action='click->password-reveal#toggle']").click

    assert_selector "input[type='password']"
  end

  def test_reveal_button_has_aria_label
    visit "/form/password_field"

    assert_selector "button[aria-label]"
  end

  def test_passes_wcag
    visit "/form/password_field"

    assert_accessible
  end
end
