class Device
  include Mongoid::Document
  store_in session: 'devices'

  field :resource_owner_id, type: Moped::BSON::ObjectId
  field :name
end
