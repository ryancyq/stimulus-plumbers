# frozen_string_literal: true

require "test_helper"

class IconHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::IconHelper

  def test_sp_icon_renders_span_for_unknown_icon
    assert_css parse_html(sp_icon("nonexistent")), "span"
  end

  def test_sp_icon_forwards_html_options
    assert_css parse_html(sp_icon("nonexistent", class: "size-6")), ".size-6"
  end

  def test_sp_icon_renders_svg_for_known_icon
    theme = Class.new(StimulusPlumbers::Themes::Base) do
      def icons
        { "check" => { elements: [{ tag: :path, d: "M1 2" }] } }
      end
    end.new

    StimulusPlumbers.config.theme.stub(:current, theme) do
      assert_includes sp_icon("check"), "<svg"
    end
  end
end
