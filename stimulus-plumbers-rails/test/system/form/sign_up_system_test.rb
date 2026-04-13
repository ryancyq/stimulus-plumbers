# frozen_string_literal: true

require_relative "../application_system_test_case"

class SignUpSystemTest < ApplicationSystemTestCase
  def test_renders_all_fields
    visit "/form/sign_up"

    assert_selector "label", text: %r{Full name}
    assert_selector "input[type='text']"
    assert_selector "label", text: %r{Email address}
    assert_selector "input[type='email']"
    assert_selector "label", text: %r{Password}
    assert_selector "input[type='password']"
    assert_selector "input[type='number']"
    assert_selector "input[type='date']"
    assert_selector "label", text: %r{Bio}
    assert_selector "textarea"
    assert_selector "label", text: %r{Male}
    assert_selector "label", text: %r{Female}
    assert_selector "label", text: %r{Other}
    assert_selector "input[type='radio']", count: 3
    assert_selector "label", text: %r{Country}
    assert_selector "select"
    assert_selector "label", text: %r{Subscribe to newsletter}
    assert_selector "input[type='checkbox']"
    assert_selector "input[type='submit'][value='Create account']"
  end

  def test_renders_hint_text
    visit "/form/sign_up"

    assert_text "We'll never share your email."
    assert_text "Tell us a little about yourself."
    assert_text "Select your country of residence."
  end

  def test_renders_required_indicators
    visit "/form/sign_up"

    assert_selector "span[aria-hidden='true']", text: "*", minimum: 3
  end

  def test_each_input_has_an_associated_label
    visit "/form/sign_up"

    assert_selector "label[for='sign_up_name']"
    assert_selector "label[for='sign_up_email']"
    assert_selector "label[for='sign_up_age']"
    assert_selector "label[for='sign_up_birth_date']"
  end

  def test_label_is_associated_with_textarea
    visit "/form/sign_up"

    textarea_id = find("textarea")[:id]

    assert_selector "label[for='#{textarea_id}']"
  end

  def test_radio_buttons_are_associated_with_labels
    visit "/form/sign_up"

    all("input[type='radio']").each do |radio|
      assert_selector "label[for='#{radio[:id]}']"
    end
  end

  def test_checkbox_is_associated_with_label
    visit "/form/sign_up"

    checkbox_id = find("input[type='checkbox']")[:id]

    assert_selector "label[for='#{checkbox_id}']"
  end

  def test_label_is_associated_with_select
    visit "/form/sign_up"

    select_id = find("select")[:id]

    assert_selector "label[for='#{select_id}']"
  end

  def test_renders_country_options
    visit "/form/sign_up"

    assert_selector "option", text: "Australia"
    assert_selector "option", text: "New Zealand"
    assert_selector "option", text: "Singapore"
    assert_selector "option", text: "United States"
  end

  def test_password_reveal_toggle
    visit "/form/sign_up"

    assert_selector "[data-controller='password-reveal']"
    find("button[data-action='click->password-reveal#toggle']").click

    assert_selector "input[type='text']"

    find("button[data-action='click->password-reveal#toggle']").click

    assert_selector "input[type='password']"
  end

  def test_reveal_button_has_aria_label
    visit "/form/sign_up"

    assert_selector "button[aria-label]"
  end

  def test_textarea_has_auto_resize_controller
    visit "/form/sign_up"

    assert_selector "textarea[data-controller='auto-resize']"
  end

  def test_renders_card
    visit "/form/sign_up"

    assert_selector "h1", text: "Create account"
    assert_selector "div"
  end

  def test_renders_avatar
    visit "/form/sign_up"

    assert_selector "span[role='img'][aria-label='Stimulus Plumbers']"
  end

  def test_renders_sign_in_button
    visit "/form/sign_up"

    assert_selector "a", text: "Sign in"
  end

  def test_passes_wcag
    visit "/form/sign_up"

    assert_accessible
  end
end
