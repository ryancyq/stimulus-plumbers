# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Checklist < Plumber::Base
      def render(label: nil, labelledby: nil, select_all: false, select_all_label: "Select all", **kwargs, &block)
        @item_states = [] if select_all
        captured = template.capture(self, &block)
        master = select_all ? render_select_all(select_all_label) : nil
        html_options = merge_html_options(
          theme.resolve(:checklist),
          kwargs,
          { role: "group", aria: labelled_aria(label, labelledby: labelledby) }
        )
        html_options = merge_html_options(html_options, select_all_wrapper_attrs) if select_all
        template.content_tag(:div, template.safe_join([master, captured].compact), **html_options)
      end

      def item(content = nil, **kwargs, &block)
        @item_states << kwargs[:checked] if @item_states && !kwargs[:readonly]
        Checklist::Item.new(template).render(content, **kwargs, &block)
      end

      private

      def render_select_all(select_all_label)
        template.content_tag(:label, **merge_html_options(theme.resolve(:checklist_item))) do
          template.safe_join([render_master_input, template.content_tag(:span, select_all_label)])
        end
      end

      def render_master_input
        template.tag.input(
          **merge_html_options(
            theme.resolve(:checklist_item_input),
            { type: "checkbox", checked: all_items_checked? || nil, data: { checklist_target: "master" } }
          )
        )
      end

      def select_all_wrapper_attrs
        { data: { controller: "checklist", action: "change->checklist#onChange" } }
      end

      def all_items_checked?
        @item_states.present? && @item_states.all? { |state| state == true }
      end
    end
  end
end
