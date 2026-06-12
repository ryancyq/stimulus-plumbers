# frozen_string_literal: true

require "test_helper"

class PlumberHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::PlumberHelper

  def test_generates_namespaced_id_without_record
    assert_match(%r{\Asp_[a-f0-9]+\z}, sp_dom_id)
  end

  def test_appends_suffix_without_record
    assert_match(%r{\Asp_[a-f0-9]+_datepicker\z}, sp_dom_id(suffix: "datepicker"))
  end

  def test_generates_unique_ids_without_record
    assert_not_equal sp_dom_id, sp_dom_id
  end

  def test_namespaces_dom_id_with_record
    record = TestRecord.new

    assert_equal "sp_#{dom_id(record)}", sp_dom_id(record)
  end

  def test_prepends_prefix_with_record
    record = TestRecord.new

    assert_equal "sp_#{dom_id(record, :edit)}", sp_dom_id(record, prefix: :edit)
  end

  def test_combines_prefix_and_suffix_with_record
    record = TestRecord.new

    assert_equal "sp_#{dom_id(record, :edit)}_my_suffix", sp_dom_id(record, prefix: :edit, suffix: :my_suffix)
  end
end
