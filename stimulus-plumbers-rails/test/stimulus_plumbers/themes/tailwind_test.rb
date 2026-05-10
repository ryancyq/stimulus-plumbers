# frozen_string_literal: true

require "test_helper"

class TailwindThemeTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_theme_name
    assert_equal "Tailwind", @theme.name
  end

  def test_resolves_all_known_components_without_error
    StimulusPlumbers::Themes::Base::SCHEMA.each_key do |component|
      result = @theme.resolve(component)

      assert_instance_of Hash, result, "expected Hash for #{component}"
    end
  end
end
