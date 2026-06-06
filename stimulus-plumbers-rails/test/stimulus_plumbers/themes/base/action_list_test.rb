# frozen_string_literal: true

require "test_helper"

class BaseThemeActionListTest < StubThemeTestCase
  def test_resolves_action_list_item
    result = @theme.resolve(:action_list_item)

    assert_instance_of Hash, result
  end
end
