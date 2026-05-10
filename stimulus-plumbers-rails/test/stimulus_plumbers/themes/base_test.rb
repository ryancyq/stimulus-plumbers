# frozen_string_literal: true

require "test_helper"

class BaseThemeTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::Base.new
  end

  def test_resolve_returns_empty_hash_for_an_unknown_component
    assert_equal({}, @theme.resolve(:nonexistent))
  end

  def test_resolve_returns_empty_hash_and_warns_for_all_known_components
    mock_logger = Minitest::Mock.new
    StimulusPlumbers::Themes::Base::SCHEMA.each_key do |_component|
      mock_logger.expect(:warn, nil, [String])
    end
    Rails.stub(:logger, mock_logger) do
      StimulusPlumbers::Themes::Base::SCHEMA.each_key do |component|
        assert_equal({}, @theme.resolve(component))
      end
    end
    mock_logger.verify
  end
end
