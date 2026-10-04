# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ModalHelper
      def sp_modal(...)
        Components::Modal.new(self).render(...)
      end

      def sp_modal_turbo(...)
        Components::Modal::Turbo.new(self).render(...)
      end

      def sp_modal_link_to(content = nil, url:, modal_id:, **kwargs, &block)
        value = modal_id.to_s
        raise ArgumentError, "modal link modal_id must be a nonblank stable id" if value.blank?

        data = (kwargs.delete(:data) || {}).dup
        native = respond_to?(:hotwire_native_app?, true) && send(:hotwire_native_app?)

        data.delete(:turbo_frame)
        data.delete("turbo_frame")
        data.delete("turbo-frame")
        data[:turbo_frame] = value unless native

        Components::Link.new(self).render(content, url: url, **kwargs.merge(data: data), &block)
      end
    end
  end
end
