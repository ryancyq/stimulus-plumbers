# frozen_string_literal: true

require_relative "../application_system_test_case"

class PopoverComponentSystemTest < ApplicationSystemTestCase
  BASE = "/rails/view_components/popover_component"

  def test_default_passes_wcag
    visit "#{BASE}/default"
    assert_accessible
  end

  def test_static_passes_wcag
    visit "#{BASE}/static"
    assert_accessible
  end
end
