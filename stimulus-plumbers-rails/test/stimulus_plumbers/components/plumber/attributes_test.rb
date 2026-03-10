# frozen_string_literal: true

require "test_helper"

module StimulusPlumbers
  module Components
    module Plumber
      class AttributesTest < Minitest::Test
        def fresh_instance
          obj = Object.new
          obj.extend(Attributes)
          obj
        end

        def test_data_attributes_are_deep_merged
          instance = fresh_instance
          instance.html_options = { data: { controller: "ctrl123" } }
          instance.html_options = { data: { "ctrl123-target": "target456" } }

          assert_equal "ctrl123", instance.html_options[:data][:controller]
          assert_equal "target456", instance.html_options[:data][:"ctrl123-target"]
        end

        def test_data_attributes_second_assignment_does_not_overwrite_first
          instance = fresh_instance
          instance.html_options = { data: { controller: "ctrl123" } }
          instance.html_options = { data: { "ctrl123-target": "target456" } }

          assert_equal 2, instance.html_options[:data].length
        end

        def test_shallow_keys_are_still_merged
          instance = fresh_instance
          instance.html_options = { id: "foo" }
          instance.html_options = { aria: { label: "bar" } }

          assert_equal "foo", instance.html_options[:id]
          assert_equal "bar", instance.html_options[:aria][:label]
        end

        def test_class_is_accumulated_not_overwritten
          instance = fresh_instance
          instance.html_options = { class: "btn" }
          instance.html_options = { class: "btn-primary" }

          assert_includes instance.html_options[:class], "btn"
          assert_includes instance.html_options[:class], "btn-primary"
        end
      end
    end
  end
end
