# frozen_string_literal: true

module HtmlAssertions
  def parse_html(html)
    Nokogiri::HTML.fragment(html)
  end

  def assert_css(doc, selector, msg = nil)
    assert_predicate doc.css(selector), :any?, msg || "Expected to find #{selector.inspect}"
  end

  def assert_no_css(doc, selector, msg = nil)
    assert_predicate doc.css(selector), :none?, msg || "Expected not to find #{selector.inspect}"
  end
end
