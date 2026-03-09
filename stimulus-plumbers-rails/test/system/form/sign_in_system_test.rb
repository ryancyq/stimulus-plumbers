# frozen_string_literal: true

require_relative "../application_system_test_case"

class SignInSystemTest < ApplicationSystemTestCase
  def test_renders_all_fields
    visit "/form/sign_in"

    assert_selector "label", text: %r{Email address}
    assert_selector "input[type='email']"
    assert_selector "label", text: %r{Password}
    assert_selector "input[type='password']"
    assert_selector "label", text: %r{Remember me}
    assert_selector "input[type='checkbox']"
    assert_selector "input[type='submit'][value='Sign in']"
  end

  def test_renders_hint_text
    visit "/form/sign_in"

    assert_text "We'll never share your email."
  end

  def test_renders_required_indicators
    visit "/form/sign_in"

    assert_selector "span[aria-hidden='true']", text: "*", minimum: 2
  end

  def test_password_reveal_toggle
    visit "/form/sign_in"

    assert_selector "[data-controller='password-reveal']"
    find("button[data-action='click->password-reveal#toggle']").click

    assert_selector "input[type='text']"

    find("button[data-action='click->password-reveal#toggle']").click

    assert_selector "input[type='password']"
  end

  def test_passes_wcag
    visit "/form/sign_in"

    assert_accessible
  end
end
