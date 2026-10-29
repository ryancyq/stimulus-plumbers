# frozen_string_literal: true

require "test_helper"

class PasswordStrengthTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::PasswordStrength.new(self)
  end

  def config
    StimulusPlumbers::Password::Requirements.build do |req|
      req.enforce(min_length: 12, max_length: 64, digit: true)
    end
  end

  def rendered
    renderer.render(input: "<input type=\"password\">".html_safe, input_id: "password", config: config)
  end

  def rendered_with_negated_rule
    no_spaces = StimulusPlumbers::Password::Requirements.build do |req|
      req.enforce(min_length: 12, max_length: 64)
      req.rule(:no_space, "No spaces", pattern: "\\s", negate: true)
    end
    renderer.render(input: "<input type=\"password\">".html_safe, input_id: "password", config: no_spaces)
  end

  def test_renders_strength_structure_and_aria
    doc = parse_html(rendered)

    assert_css doc, "[data-controller='password-strength'] input[type='password']"
    assert_css doc, "meter#password_meter"
    assert_css doc, "p[data-password-strength-target='level'][aria-live='polite']"
    assert_css doc, "ul#password_rules li[data-rule='length']"
    assert_css doc, "ul#password_rules li[data-rule='digit']"
  end

  def test_renders_rules_an_empty_password_already_meets_as_met
    doc = parse_html(rendered_with_negated_rule)
    met = doc.at_css("li[data-rule='no_space']")

    assert_equal "true", met["data-satisfied"]
    assert_nil met.at_css("[data-password-strength-target='checkIcon']")["hidden"]
    assert met.at_css("[data-password-strength-target='closeIcon']")["hidden"]
    assert_equal "false", doc.at_css("li[data-rule='length']")["data-satisfied"]
  end

  def test_renders_the_empty_password_level_and_meter_value
    doc = parse_html(rendered_with_negated_rule)

    assert_equal "50", doc.at_css("meter#password_meter")["value"]
    assert_equal "Fine password", doc.at_css("p[data-password-strength-target='level']").text
  end

  def test_renders_level_wording_and_rules_heading
    doc = parse_html(rendered)

    assert_equal "Weak password", doc.at_css("p[data-password-strength-target='level']").text
    assert_includes doc.text, "It's better to have:"
  end

  def test_builds_ids_from_the_input_id
    assert_equal "x_meter", StimulusPlumbers::Components::PasswordStrength.meter_id_for("x")
    assert_equal "x_rules", StimulusPlumbers::Components::PasswordStrength.rules_id_for("x")
  end
end
