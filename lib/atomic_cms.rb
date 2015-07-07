require 'atomic_cms/editor'
require 'atomic_cms/has_components'
require 'atomic_cms/engine' if defined?(Rails)

module AtomicAssets
  class Component
    include AtomicCms::Editor
  end
end

module AtomicCms
  def routes(target)
    target.resources :components, only: [:edit]
  end
end
