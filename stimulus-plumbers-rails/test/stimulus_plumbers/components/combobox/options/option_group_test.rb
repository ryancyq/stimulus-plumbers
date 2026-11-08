# frozen_string_literal: true

require "test_helper"

class ComboboxOptionsOptionGroupTest < ActionView::TestCase
  def render_group(id: "g1", &block)
    parse_html(
      StimulusPlumbers::Components::Combobox::Options::OptionGroup.new(self).render(label: "Americas", id: id) do
        block ? capture(&block) : ""
      end
    )
  end

  def test_wraps_a_group_in_a_presentational_item
    assert_css render_group, "li[role='none'] > ul[role='group'][aria-labelledby='g1']"
  end

  def test_labels_the_group_with_a_presentational_item
    assert_css render_group, "ul[role='group'] > li#g1[role='none']", text: "Americas"
  end

  def test_renders_its_options_inside_the_group
    doc = render_group { tag.li("Canada", role: "option") }

    assert_css doc, "ul[role='group'] > li[role='option']", text: "Canada"
  end

  def test_omits_labelledby_without_an_id
    assert_no_css render_group(id: nil), "[aria-labelledby]"
  end

  def test_applies_the_option_group_theme_as_a_class
    original = StimulusPlumbers.config.theme.current
    StimulusPlumbers.config.theme.use(group_theme)

    assert_css render_group, "li.sp-group[role='none']"
  ensure
    StimulusPlumbers.config.theme.use(original)
  end

  def test_applies_the_group_label_theme_to_the_label
    original = StimulusPlumbers.config.theme.current
    StimulusPlumbers.config.theme.use(group_theme)

    assert_css render_group, "li#g1.sp-group-label[role='none']", text: "Americas"
  ensure
    StimulusPlumbers.config.theme.use(original)
  end

  def group_theme
    Class.new(StimulusPlumbers::Themes::Base) do
      def combobox_option_group_classes(**)
        { classes: "sp-group" }
      end

      def combobox_option_group_label_classes(**)
        { classes: "sp-group-label" }
      end
    end.new
  end
end
