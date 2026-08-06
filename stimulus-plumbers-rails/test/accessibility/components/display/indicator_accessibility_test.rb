# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class IndicatorAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/indicator"
  end

  def test_indicator_paired_with_a_label_passes_wcag
    assert_accessible context: "#indicator-paired"
  end

  def test_indicator_without_a_label_fails_wcag
    violations = page.evaluate_async_script(<<~JS, "#indicator-unpaired")
      var context = arguments[0];
      var done = arguments[arguments.length - 1];
      axe.run(context, function(err, results) {
        done(err ? [] : results.violations);
      });
    JS

    assert_predicate violations, :any?, "expected an axe violation for an unlabeled indicator"
  end
end
