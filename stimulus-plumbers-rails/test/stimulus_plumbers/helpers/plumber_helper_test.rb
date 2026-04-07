# frozen_string_literal: true

require "test_helper"

class PlumberHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::PlumberHelper

  def test_generates_unique_id_without_record
    assert_not_equal sp_dom_id(nil, "datepicker"), sp_dom_id(nil, "datepicker")
  end

  def test_id_includes_suffix_without_record
    assert_match(%r{\Adatepicker_[a-f0-9]+\z}, sp_dom_id(nil, "datepicker"))
  end

  def test_delegates_to_dom_id_with_record
    record = TestRecord.new

    assert_equal dom_id(record, :my_suffix), sp_dom_id(record, :my_suffix)
  end
end
