# frozen_string_literal: true

require "test_helper"

class PlumberBaseTest < ActionView::TestCase
  class ConcreteBase < StimulusPlumbers::Plumber::Base
    def render
      "rendered"
    end
  end

  def base
    ConcreteBase.new(self)
  end

  def test_exposes_template
    assert_equal self, base.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme.current, base.theme
  end
end
