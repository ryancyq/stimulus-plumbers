# frozen_string_literal: true

require_relative "../application_system_test_case"

class ButtonComponentSystemTest < ApplicationSystemTestCase
  BASE = "/rails/view_components/button_component"

  def test_default_passes_wcag
    visit "#{BASE}/default"
    assert_accessible
  end

  def test_as_link_passes_wcag
    visit "#{BASE}/as_link"
    assert_accessible
  end
end
