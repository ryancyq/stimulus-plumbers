# frozen_string_literal: true

require_relative "../application_system_test_case"

class ActionListComponentSystemTest < ApplicationSystemTestCase
  BASE = "/rails/view_components/action_list_component"

  def test_default_passes_wcag
    visit "#{BASE}/default"
    assert_accessible
  end

  def test_with_sections_passes_wcag
    visit "#{BASE}/with_sections"
    assert_accessible
  end
end
