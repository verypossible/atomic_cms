module ComponentHelper
  def add_option(option, output = nil)
    return unless option
    return output if output
    option
  end

  def markdown(text)
    return unless text
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(text).html_safe
  end

  def markdown_help_url
    "http://nestacms.com/docs/creating-content/markdown-cheat-sheet"
  end

  def render_children(children)
    return children unless children.present? && children.is_a?(Array)
    children.map(&:render).reduce(:+)
  end
end
