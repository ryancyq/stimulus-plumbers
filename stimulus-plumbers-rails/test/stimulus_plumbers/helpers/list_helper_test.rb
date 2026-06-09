# frozen_string_literal: true

require "test_helper"

class ListHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::ListHelper

  def test_sp_list_renders_a_list
    assert_css parse_html(sp_list { "" }), "ul[role='list']"
  end
end
