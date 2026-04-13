# frozen_string_literal: true

require "test_helper"

class PopoverHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::PopoverHelper

  def test_renders_div
    html = sp_popover { |_p| nil }

    assert_includes html, "<div"
  end

  def test_wraps_content_in_template_by_default
    html = sp_popover do |p|
      p.content { "body" }
    end

    assert_includes html, "<template"
  end

  def test_no_template_when_not_interactive
    html = sp_popover(interactive: false) do |p|
      p.content { "body" }
    end

    refute_includes html, "<template"
  end

  def test_renders_activator
    html = sp_popover do |p|
      p.activator { "trigger" }
    end

    assert_includes html, "trigger"
  end

  def test_merges_custom_class
    html = sp_popover(class: "dropdown") { |_p| nil }

    assert_includes html, "dropdown"
  end
end
