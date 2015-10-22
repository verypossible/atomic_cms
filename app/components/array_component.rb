class ArrayComponent < AtomicAssets::Component
  def render
    children.map(&:render).reduce(:+)
  end

  def edit
    rtn = cms_fields
    rtn << render_child_array
    rtn.html_safe
  end
end
