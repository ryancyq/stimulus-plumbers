# frozen_string_literal: true

require_relative "../../test_helper"

class StimulusControllerDocsLoaderTest < Minitest::Test
  def setup
    @docs = StimulusPlumbers::MCP::StimulusControllerDocsLoader.call
  end

  def test_returns_hash_of_markdown_by_doc_key
    assert_kind_of Hash, @docs
    assert @docs.key?(:modal), "expected :modal key, got #{@docs.keys.inspect}"
    assert_kind_of String, @docs[:modal]
    assert_match(%r{modal}i, @docs[:modal])
  end

  def test_covers_all_known_controller_doc_families
    expected = %i[calendar clipboard combobox dismisser flipper input-clearable
                  input-formatter modal panner popover timeline].map(&:to_s).map(&:to_sym)

    assert_equal expected.sort, @docs.keys.sort
  end
end
