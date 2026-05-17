# frozen_string_literal: true

require "test_helper"

class BaseThemeLayoutTest < StubThemeTestCase
  def test_divider_resolves_without_error
    assert_equal({}, @theme.resolve(:divider))
  end

  def test_popover_resolves_without_error
    assert_equal({}, @theme.resolve(:popover))
  end
end
