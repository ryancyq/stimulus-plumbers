# frozen_string_literal: true

require "test_helper"

class BaseThemeAvatarTest < Minitest::Test
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

  def test_coerces_invalid_size_to_default_and_warns
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unknown value :xl}])
    Rails.stub(:logger, mock_logger) do
      @theme.resolve(:avatar, size: :xl)
    end
    mock_logger.verify
  end
end
