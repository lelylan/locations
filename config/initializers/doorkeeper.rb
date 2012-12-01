# Doorkiper configuration
Doorkeeper.configure do
  orm :mongoid3
end

# Doorkeeper models extensions
Locations::Application.config.to_prepare do
  Doorkeeper::AccessToken.class_eval { store_in collection: :oauth_access_tokens, session: 'people' }
  Doorkeeper::AccessGrant.class_eval { store_in collection: :oauth_access_grants, session: 'people' }
  Doorkeeper::Application.class_eval { store_in collection: :oauth_applications, session: 'people' }
end

# 401 rendering
module Doorkeeper
  module Helpers
    module Filter
      module ClassMethods
        def doorkeeper_for(*args)
          doorkeeper_for = DoorkeeperForBuilder.create_doorkeeper_for(*args)
          before_filter doorkeeper_for.filter_options do
            return if doorkeeper_for.validate_token(doorkeeper_token)
            self.class.serialization_scope :request
            render json: {}, status: 401, serializer: ::NotAuthorizedSerializer and return
          end
        end
      end
    end
  end
end
