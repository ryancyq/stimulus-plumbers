# frozen_string_literal: true

require "test_helper"

module StimulusPlumbers
  module Components
    module Plumber
      class HtmlOptionsTest < Minitest::Test
        def instance
          obj = Object.new
          obj.extend(HtmlOptions)
          obj
        end

        def test_deep_merges_data_attributes
          result = instance.merge_html_options(
            { data: { controller: "ctrl" } },
            data: { "ctrl-target": "el" }
          )

          assert_equal "ctrl", result[:data][:controller]
          assert_equal "el",   result[:data][:"ctrl-target"]
        end

        def test_overrides_do_not_clobber_defaults_data
          result = instance.merge_html_options(
            { data: { controller: "ctrl", action: "click->ctrl#act" } },
            data: { foo: "bar" }
          )

          assert_equal "ctrl",              result[:data][:controller]
          assert_equal "click->ctrl#act",   result[:data][:action]
          assert_equal "bar",               result[:data][:foo]
        end

        def test_converts_classes_to_class
          result = instance.merge_html_options(classes: "btn btn-primary")

          assert_equal "btn btn-primary", result[:class]
          assert_nil result[:classes]
        end

        def test_merges_class_and_classes
          result = instance.merge_html_options(class: "btn", classes: "btn-primary")

          assert_includes result[:class], "btn"
          assert_includes result[:class], "btn-primary"
        end

        def test_preserves_other_top_level_keys
          result = instance.merge_html_options(id: "foo", aria: { label: "bar" })

          assert_equal "foo", result[:id]
          assert_equal "bar", result[:aria][:label]
        end
      end
    end
  end
end
