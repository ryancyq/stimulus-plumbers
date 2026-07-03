# frozen_string_literal: true

require_relative "../../test_helper"

class IconsLoaderTest < Minitest::Test
  def setup
    @icons = StimulusPlumbers::MCP::IconsLoader.call
  end

  def test_icons_is_an_array_of_strings
    assert_instance_of Array, @icons
    refute_empty @icons
    assert(@icons.all?(String))
  end
end
