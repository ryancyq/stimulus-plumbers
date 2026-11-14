# frozen_string_literal: true

require "pathname"

module StimulusPlumbers
  module MCP
    # Rewrites a served doc's relative links, which resolve only inside the repo: a doc the server serves
    # becomes its resource URI, any other repo file a GitHub URL at the stimulus_plumbers gem's release tag.
    module DocLinks
      REPO_URL    = "https://github.com/ryancyq/stimulus-plumbers/blob"
      FENCE       = %r{\A\s*(```|~~~)}
      INLINE_CODE = %r{(`[^`]*`)}
      LINK        = %r{\]\(([^)\s]+)\)}
      KEEP        = %r{\A(?:[a-z][a-z0-9+.-]*:|//|#)}i
      RESOURCES   = {
        %r{\Astimulus-plumbers-rails/docs/component/([\w-]+)\.md\z} => "component://%s/docs",
        %r{\Astimulus-plumbers/docs/component/([\w-]+)\.md\z}       => "controller://docs/%s",
        %r{\AARIA\.md\z}                                            => "aria://reference"
      }.freeze

      class << self
        # `source` is the doc's path in the repo, e.g. "stimulus-plumbers/docs/component/modal.md".
        def rewrite(content, source:)
          fenced = false
          content.each_line.map do |line|
            next line if fenced && !line.match?(FENCE)

            if line.match?(FENCE)
              fenced = !fenced
              next line
            end

            line.split(INLINE_CODE).each_with_index.map { |part, index| index.odd? ? part : links(part, source) }.join
          end.join
        end

        private

        def links(text, source)
          text.gsub(LINK) { "](#{target(Regexp.last_match(1), source)})" }
        end

        def target(link, source)
          return link if link.match?(KEEP)

          path, anchor = link.split("#", 2)
          repo_path    = Pathname.new(File.dirname(source)).join(path).cleanpath.to_s
          return link if repo_path.start_with?("..")

          uri = resource(repo_path) || "#{REPO_URL}/#{ref}/#{repo_path}"
          anchor ? "#{uri}##{anchor}" : uri
        end

        def resource(repo_path)
          RESOURCES.each do |pattern, uri|
            match = pattern.match(repo_path)
            return format(uri, *match.captures) if match
          end
          nil
        end

        def ref
          @ref ||= "stimulus-plumbers-rails/v#{Gem::Specification.find_by_name("stimulus_plumbers").version}"
        rescue Gem::MissingSpecError
          @ref = "main"
        end
      end
    end
  end
end
