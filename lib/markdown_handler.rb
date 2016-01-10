class MarkdownHandler
  class << self
    def call(template)
      compiled_source = erb.call(template)
      "MarkdownHandler.render(begin;#{compiled_source};end)"
    end

    def render(text)
      markdown.render(text).html_safe
    end

    private

      def markdown
        @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, fenced_code_blocks: true, autolink: true, space_after_headers: true)
      end

      def erb
        @erb ||= ActionView::Template.registered_template_handler(:erb)
      end
  end
end