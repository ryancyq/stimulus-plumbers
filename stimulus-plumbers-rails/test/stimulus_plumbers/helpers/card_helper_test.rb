# frozen_string_literal: true

require "test_helper"

class CardHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::CardHelper

  def test_sp_card_renders_a_card
    assert_css parse_html(sp_card { |card| card.with_title("Card") }), "div"
  end
end
