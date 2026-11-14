# frozen_string_literal: true

require_relative "../../test_helper"

class DocLinksTest < Minitest::Test
  RAILS_DOC = "stimulus-plumbers-rails/docs/component/combobox.md"
  JS_DOC    = "stimulus-plumbers/docs/component/combobox.md"

  def rewrite(markdown, source: RAILS_DOC)
    StimulusPlumbers::MCP::DocLinks.rewrite(markdown, source: source)
  end

  def test_a_rails_component_doc_becomes_its_component_resource
    assert_equal "[Calendar](component://calendar/docs#turbo)", rewrite("[Calendar](calendar.md#turbo)")
  end

  def test_a_js_component_doc_becomes_its_controller_resource
    assert_equal "[JS](controller://docs/combobox#combobox-datetime)",
                 rewrite("[JS](../../../stimulus-plumbers/docs/component/combobox.md#combobox-datetime)")
  end

  def test_aria_becomes_the_aria_resource
    assert_equal "[ARIA](aria://reference#combobox)", rewrite("[ARIA](../../../ARIA.md#combobox)", source: JS_DOC)
  end

  def test_an_unserved_repo_file_becomes_a_github_url_at_the_release_tag
    version = Gem::Specification.find_by_name("stimulus_plumbers").version

    assert_equal "[Flipper](https://github.com/ryancyq/stimulus-plumbers/blob/stimulus-plumbers-rails/v#{version}/" \
                 "stimulus-plumbers/docs/plumber/flipper.md)",
                 rewrite("[Flipper](../plumber/flipper.md)", source: JS_DOC)
  end

  def test_external_links_anchors_and_code_stay_as_written
    markdown = <<~MD
      [MDN](https://developer.mozilla.org) [Options](#options) `[a](b.md)`
      ```js
      items[0](calendar.md)
      ```
    MD

    assert_equal markdown, rewrite(markdown)
  end

  def test_served_docs_link_only_to_served_resources_or_the_web
    uris = served_docs.join("\n").scan(%r{\]\(([^)\s]+)\)}).flatten.map { _1.split("#").first.to_s }.uniq
    resources = uris.reject { |uri| uri.empty? || uri.match?(%r{\A(?:https?|mailto):}) }

    assert_empty(resources.reject { |uri| served?(uri) })
  end

  private

  def components
    @components ||= StimulusPlumbers::MCP::ComponentDocsLoader.call
  end

  def controllers
    @controllers ||= StimulusPlumbers::MCP::ControllerDocsLoader.call
  end

  def served_docs
    components.values.map { _1[:content] } + controllers.values +
      [StimulusPlumbers::MCP::AriaLoader.call, *StimulusPlumbers::MCP::GuideLoader.call.values]
  end

  def served?(uri)
    case uri
    when %r{\Acomponent://(.+)/docs\z} then components.key?(Regexp.last_match(1).to_sym)
    when %r{\Acontroller://docs/(.+)\z} then controllers.key?(Regexp.last_match(1).to_sym)
    else uri == "aria://reference"
    end
  end
end
