class ArrayComponent < AtomicAssets::Component
  def children
    options[:children] ||= []
  end

  def render
    children.map(&:render).reduce(:+)
  end

  def edit
    rtn = cms_fields
    rtn << cms_array(:children) do
      rtn2 = ""
      children.each do |child|
        rtn2 << cms_array_node { child.edit }
      end
      rtn2.html_safe
    end
  end
end
