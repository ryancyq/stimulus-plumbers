# frozen_string_literal: true

require "test_helper"

class BaseThemeLayoutTest < StubThemeTestCase
  def test_divider_resolves_without_error
    assert_equal({}, @theme.resolve(:divider))
  end

  def test_popover_resolves_without_error
    assert_equal({}, @theme.resolve(:popover))
  end

  def test_popover_placement_schema_accepts_all_semantic_values
    placements = StimulusPlumbers::Themes::Schema::Popover::Ranges::PLACEMENT

    placements.each do |placement|
      assert_equal placement, @theme.send(:validate, :popover, placement: placement)[:placement]
    end
  end

  def test_popover_placement_schema_falls_back_for_an_unknown_value
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{popover#placement received unknown value :sideways}])

    Rails.stub(:logger, mock_logger) do
      assert_equal :block_end_start, @theme.send(:validate, :popover, placement: :sideways)[:placement]
    end
    mock_logger.verify
  end
end
