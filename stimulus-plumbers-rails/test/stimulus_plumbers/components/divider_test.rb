# frozen_string_literal: true

require "test_helper"

class DividerComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Divider.new(self)
  end

  def test_renders_hr_element
    assert_includes renderer.render, "<hr"
  end

  def test_merges_custom_html_options
    assert_includes renderer.render(class: "my-divider"), "my-divider"
  end
end
