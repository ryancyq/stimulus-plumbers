# frozen_string_literal: true

require "test_helper"

class ResolveValueTest < ActiveSupport::TestCase
  include StimulusPlumbers::ResolveValue

  Record = Struct.new(:opening, :closing)

  Opening = Struct.new(:fallback) do
    def call(record)
      record.opening || fallback
    end
  end

  def test_a_proc_takes_the_record_unless_it_takes_nothing
    record = Record.new("09:00", "17:00")

    assert_equal "09:00".."17:00", resolve_value(record, ->(each) { each.opening..each.closing })
    assert_equal "17:00", resolve_value(record, -> { "17:00" })
  end

  def test_a_symbol_calls_the_record
    assert_equal "09:00", resolve_value(Record.new("09:00"), :opening)
  end

  def test_a_callable_takes_the_record
    assert_equal "08:00", resolve_value(Record.new, Opening.new("08:00"))
  end

  def test_any_other_value_is_itself
    assert_equal "09:00", resolve_value(nil, "09:00")
  end
end
