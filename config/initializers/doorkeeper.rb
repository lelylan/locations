# Doorkiper configuration
Doorkeeper.configure do
  orm :mongoid
end

# Doorkeeper models extensions
Locations::Application.config.to_prepare do
  Doorkeeper::AccessToken.class_eval { store_in session: 'people' }
  Doorkeeper::AccessGrant.class_eval { store_in session: 'people' }
  Doorkeeper::Application.class_eval { store_in session: 'people' }
end
