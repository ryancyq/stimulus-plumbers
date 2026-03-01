# frozen_string_literal: true

require_relative "../application_system_test_case"

class DividerComponentSystemTest < ApplicationSystemTestCase
  BASE = "/rails/view_components/divider_component"

  def test_default_passes_wcag
    visit "#{BASE}/default"
    assert_accessible
  end
end
