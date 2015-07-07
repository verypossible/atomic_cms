AtomicCms::Engine.routes.draw do
  resources :components, only: [:edit]
end
