# frozen_string_literal: true

require "test_helper"

class BaseThemeModalTest < StubThemeTestCase
  def test_modal_components_resolve_without_a_theme
    %i[modal_wrapper modal modal_backdrop modal_header modal_title modal_body modal_footer modal_turbo].each do |component|
      assert_equal({}, @theme.resolve(component))
    end
  end

  def test_modal_size_schema_accepts_the_supported_range
    assert_equal :lg, @theme.send(:validate, :modal, size: :lg)[:size]
  end

  def test_modal_size_schema_falls_back_for_an_unknown_value
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{modal#size received unknown value :wide}])

    Rails.stub(:logger, mock_logger) do
      assert_equal :md, @theme.send(:validate, :modal, size: :wide)[:size]
    end
    mock_logger.verify
  end
end
