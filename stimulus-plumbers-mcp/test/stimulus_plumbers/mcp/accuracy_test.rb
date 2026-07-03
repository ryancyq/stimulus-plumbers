# frozen_string_literal: true

require_relative "../../test_helper"

# Cross-checks that docs/component/*.md stays in sync with the Ruby source.
# Schema values come from source constants (always authoritative).
# For each documented component that also exists in schema, every valid param value
# must appear in the PARSED signature option tables (not just anywhere in the markdown).
# field_as values are checked against raw form.md content (their table format differs).
class AccuracyTest < Minitest::Test
  def setup
    @schema = StimulusPlumbers::MCP::ComponentSchemaLoader.call
    @docs   = StimulusPlumbers::MCP::ComponentDocsLoader.call
  end

  # Flatten all text from the parsed option tables (option name, default, description)
  # and slot descriptions — the authoritative API surface extracted by ComponentDocsLoader.
  def signature_text(signature)
    option_texts = signature[:helpers].flat_map do |h|
      h[:options].flat_map { |o| [o[:option], o[:default].to_s, o[:description]] }
    end
    (option_texts + signature[:slots].map { |s| s[:description] }).join("\n")
  end

  def missing_signature_values(comp)
    sig_text = signature_text(@docs[comp][:signature])
    @schema[:components][comp].flat_map do |param, meta|
      next [] unless meta[:valid].is_a?(Array) && meta[:valid].size > 1

      meta[:valid]
        .reject { |v| sig_text.include?(":#{v}") }
        .map { |v| "#{comp}.#{param}: :#{v} missing from parsed signature options" }
    end
  end

  def test_schema_valid_values_in_signature_options
    failures = (@docs.keys & @schema[:components].keys).flat_map { |comp| missing_signature_values(comp) }

    assert_empty failures, failures.join("\n")
  end

  def test_field_as_values_documented
    schema_as   = @schema[:field_as][:field].map(&:to_s)
    doc_content = @docs[:form][:content]

    schema_as.each do |as_value|
      assert_includes doc_content,
                      ":#{as_value}",
                      "form.md does not document f.field as: :#{as_value}"
    end
  end

  def test_collection_field_as_values_documented
    schema_as   = @schema[:field_as][:collection_field].map(&:to_s)
    doc_content = @docs[:form][:content]

    schema_as.each do |as_value|
      assert_includes doc_content,
                      ":#{as_value}",
                      "form.md does not document f.collection_field as: :#{as_value}"
    end
  end

  def test_choice_as_values_documented
    schema_as   = @schema[:field_as][:choice].map(&:to_s)
    doc_content = @docs[:form][:content]

    schema_as.each do |as_value|
      assert_includes doc_content,
                      ":#{as_value}",
                      "form.md does not document f.choice as: :#{as_value}"
    end
  end
end
