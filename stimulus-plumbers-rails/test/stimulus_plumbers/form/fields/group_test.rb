# frozen_string_literal: true

require "test_helper"

class FormFieldsGroupTest < ActionView::TestCase
  def group(...)
    StimulusPlumbers::Form::Fields::Group.new(self).render(...)
  end

  def test_renders_div_with_block_content
    html = group { "content" }

    assert_includes html, "<div"
    assert_includes html, "content"
  end

  def test_accepts_layout_and_error_options
    assert_includes group(layout: :stacked, error: false) { "" }, "<div"
    assert_includes group(layout: :inline, error: true) { "" }, "<div"
  end
end
