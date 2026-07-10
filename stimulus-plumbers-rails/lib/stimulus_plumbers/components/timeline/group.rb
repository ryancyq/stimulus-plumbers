# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Timeline
      class Group < Plumber::Base
        def render(orientation: :vertical, **kwargs, &block)
          @orientation = orientation
          content = template.capture(self, &block)
          html_options = merge_html_options(theme.resolve(:timeline_group), kwargs)
          template.content_tag(:div, content, **html_options)
        end

        def section(date:, datetime: nil, **kwargs, &block)
          inner_tl = Timeline.new(template)
          inner_tl.instance_variable_set(:@orientation, @orientation)
          inner_tl.instance_variable_set(:@interactive, false)

          events_html  = template.capture(inner_tl, &block)
          section_html = template.content_tag(:div, **merge_html_options(theme.resolve(:timeline_group_section), kwargs)) do
            render_section_body(date: date, datetime: datetime, events_html: events_html)
          end
          template.concat(section_html)
        end

        private

        def render_section_body(date:, datetime:, events_html:)
          date_attrs = merge_html_options(
            theme.resolve(:timeline_group_section_date),
            datetime ? { datetime: datetime } : {}
          )
          list_attrs = merge_html_options(theme.resolve(:timeline_group_section_list, orientation: @orientation))
          template.safe_join(
            [
              template.content_tag(:time, date, **date_attrs),
              template.content_tag(:ol, events_html, **list_attrs)
            ]
          )
        end
      end
    end
  end
end
