# frozen_string_literal: true

require_relative "../application_system_test_case"

class ProfileSystemTest < ApplicationSystemTestCase
  # ── Avatar ──────────────────────────────────────────────────────────
  def test_renders_avatar
    visit "/components/profile"

    assert_selector "span[role='img'][aria-label='Jane Doe']"
  end

  # ── Card ────────────────────────────────────────────────────────────
  def test_renders_profile_card
    visit "/components/profile"

    assert_text "Jane Doe"
    assert_text "jane@example.com"
  end

  def test_renders_card_section_with_title
    visit "/components/profile"

    assert_selector "h3", text: "About"
    assert_text "Software engineer passionate about accessible UI components."
  end

  # ── Button group ────────────────────────────────────────────────────
  def test_renders_button_group
    visit "/components/profile"

    assert_selector "button", text: "Edit profile"
    assert_selector "button", text: "Change password"
  end

  # ── Action list ─────────────────────────────────────────────────────
  def test_renders_card_titles
    visit "/components/profile"

    assert_selector "h2", text: "Profile"
    assert_selector "h2", text: "Preferences"
  end

  def test_renders_action_list_section_headings
    visit "/components/profile"

    assert_selector "p", text: "Notifications"
    assert_selector "p", text: "Account"
  end

  def test_renders_action_list_items
    visit "/components/profile"

    assert_selector "button", text: "Email notifications"
    assert_selector "button", text: "Push notifications"
    assert_selector "button", text: "SMS alerts"
    assert_selector "a",      text: "Privacy settings"
    assert_selector "a",      text: "Connected accounts"
  end

  # ── Popover ─────────────────────────────────────────────────────────
  def test_renders_popover_activator
    visit "/components/profile"

    assert_selector "button", text: "More options"
  end

  def test_popover_content_is_in_template_tag
    visit "/components/profile"

    assert_selector "template", visible: :all
  end

  # ── Date picker ─────────────────────────────────────────────────────
  def test_renders_date_picker_navigation
    visit "/components/profile"

    assert_selector "[data-controller='calendar-month']"
    assert_selector "button[data-calendar-month-target='previous']"
    assert_selector "button[data-calendar-month-target='next']"
  end

  def test_renders_date_picker_month_year_targets
    visit "/components/profile"

    assert_selector "[data-calendar-month-target='month']"
    assert_selector "[data-calendar-month-target='year']"
  end

  def test_renders_date_picker_grids
    visit "/components/profile"

    assert_selector "[data-calendar-month-target='daysOfWeek']"
    assert_selector "[data-calendar-month-target='daysOfMonth'][role='grid']"
  end

  # ── Accessibility ───────────────────────────────────────────────────
  def test_passes_wcag
    visit "/components/profile"

    assert_accessible
  end
end
