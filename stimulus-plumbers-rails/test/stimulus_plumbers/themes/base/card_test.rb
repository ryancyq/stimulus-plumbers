# frozen_string_literal: true

require "test_helper"

class BaseThemeCardTest < StubThemeTestCase
  def test_card_resolves_without_error
    assert_equal({}, @theme.resolve(:card))
  end

  def test_card_header_resolves_without_error
    assert_equal({}, @theme.resolve(:card_header))
  end

  def test_card_title_resolves_without_error
    assert_equal({}, @theme.resolve(:card_title))
  end

  def test_card_icon_resolves_without_error
    assert_equal({}, @theme.resolve(:card_icon))
  end

  def test_card_body_resolves_without_error
    assert_equal({}, @theme.resolve(:card_body))
  end

  def test_card_action_resolves_without_error
    assert_equal({}, @theme.resolve(:card_action))
  end
end
