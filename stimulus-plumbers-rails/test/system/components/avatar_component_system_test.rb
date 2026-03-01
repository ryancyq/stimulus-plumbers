# frozen_string_literal: true

require_relative "../application_system_test_case"

class AvatarComponentSystemTest < ApplicationSystemTestCase
  BASE = "/rails/view_components/avatar_component"

  def test_with_name_passes_wcag
    visit "#{BASE}/with_name"
    assert_accessible
  end

  def test_with_image_passes_wcag
    visit "#{BASE}/with_image"
    assert_accessible
  end
end
