AtomicCms::Engine.routes.draw do
  resources :components, only: [:edit]
  resources :media, only: [:create]
end
