Locations::Application.routes.draw do
  resources :locations, defaults: { format: 'json' }
end
