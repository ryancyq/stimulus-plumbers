# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Plumber
    module LinkRenderer
      extend ActiveSupport::Concern

      private

      def build_link_or_button(url: nil, **kwargs, &block)
        if url.present?
          build_link(url: url, **kwargs, &block)
        else
          build_button(**kwargs, &block)
        end
      end

      def build_link(url:, active: false, target: nil, **kwargs, &block)
        html_options = merge_html_options(
          kwargs,
          (active ? { aria: { current: "page" } } : {})
        )
        template.content_tag(:a, href: url, target: target, **html_options) do
          template.capture(&block)
        end
      end

      def build_button(active: false, **kwargs, &block)
        html_options = merge_html_options(
          kwargs,
          (active ? { aria: { current: true } } : {})
        )
        template.content_tag(:button, type: "button", **html_options) do
          template.capture(&block)
        end
      end
    end
  end
end
