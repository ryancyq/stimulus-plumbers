# frozen_string_literal: true

require "test_helper"

class BaseThemeCardTest < StubThemeTestCase
  def test_card_resolves_without_error
    assert_equal({}, @theme.resolve(:card))
  end

  def test_card_section_resolves_without_error
    assert_equal({}, @theme.resolve(:card_section))
  end
end
