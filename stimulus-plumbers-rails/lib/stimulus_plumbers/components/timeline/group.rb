# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Timeline
      class Group < Plumber::Base
        def render(**kwargs, &block)
          content = template.capture(self, &block)
          html_options = merge_html_options(theme.resolve(:timeline_group), kwargs)
          template.content_tag(:div, content, **html_options)
        end

        def section(date:, datetime: nil, **kwargs, &block)
          inner_tl = Timeline.new(template)
          inner_tl.instance_variable_set(:@orientation, :vertical)
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
          template.safe_join(
            [
              template.content_tag(:time, date, **date_attrs),
              template.content_tag(:ol, events_html, **merge_html_options(theme.resolve(:timeline_group_section_list)))
            ]
          )
        end
      end
    end
  end
end
