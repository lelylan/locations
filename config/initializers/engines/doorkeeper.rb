# Doorkeeper models extensions
Locations::Application.config.to_prepare do
  Doorkeeper::AccessToken.class_eval { store_in session: 'default' }
  Doorkeeper::AccessGrant.class_eval { store_in session: 'default' }
  Doorkeeper::Application.class_eval { store_in session: 'default' }
end
