# Extension to let serializers to be cached based on
# {class name}/{instance id}-{instance updated at}/to-json
#
# This extension lets you create a fragment cache for all
# serialized json with an autoexpiring key. In fact if you
# update your resource, everything changes.
#
# Example.
#
#   DeviceSerializer < ApplicationSerializer
#     cached true

class ApplicationSerializer < ActiveModel::Serializer

  class_attribute :perform_caching

  class << self

    # Confugure the usage of the cache (or not)
    def cached(value = true)
      self.perform_caching = value
    end

  end

  # Cache entire JSON string
  def to_json(*args)
    if perform_caching?
      Rails.cache.fetch expand_cache_key(self.class.to_s.underscore, object.cache_key, 'to-json') do
        super
      end
    else
      super
    end
  end

  # Check if cashing is active
  def perform_caching?
    ActionController::Base.perform_caching && perform_caching && Rails.cache && object.respond_to?(:cache_key)
  end

  # Cache key helper
  def expand_cache_key(*args)
    ActiveSupport::Cache.expand_cache_key(args)
  end

  # We are not interested in storing associations as we work hard on modeling.
  # Anyway keeo this in consideration when using associations.
  #
  # Cache individual Hash objects before serialization
  # This also makes them available to associated serializers
  #
  #def serializable_hash
    #if perform_caching?
      #Rails.cache.fetch expand_cache_key([self.class.to_s.underscore, object.cache_key, 'serializable-hash']) do
        #super
      #end
    #else
      #super
    #end
  #end
end
