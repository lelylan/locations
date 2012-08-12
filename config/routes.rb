Locations::Application.routes.draw do
  resources :locations, defaults: { format: 'json' } do
    resources :descendants, only: %w(index)
  end
end
