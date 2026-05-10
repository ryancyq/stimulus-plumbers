# frozen_string_literal: true

require "test_helper"

class BaseThemeCardTest < Minitest::Test
  def setup
    @theme = build_stub_theme
  end

  def build_stub_theme
    Class.new(StimulusPlumbers::Themes::Base) do
      private

      StimulusPlumbers::Themes::Base::SCHEMA.each_key do |component|
        define_method(:"#{component}_classes") { |**| {} }
      end
    end.new
  end

  def test_card_resolves_without_error
    assert_equal({}, @theme.resolve(:card))
  end

  def test_card_section_resolves_without_error
    assert_equal({}, @theme.resolve(:card_section))
  end
end
