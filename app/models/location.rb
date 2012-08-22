class Location
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Ancestry
  include Resourceable

  field :resource_owner_id, type: Moped::BSON::ObjectId
  field :name
  field :type
  field :device_ids, type: Array

  attr_accessor  :parenty, :locations, :devices
  attr_protected :resource_owner_id, :location_ids, :device_ids

  has_ancestry orphan_strategy: :rootify

  validates :resource_owner_id, presence: true
  validates :name, presence: true
  validates :type, presence: true, inclusion: { in: Settings.locations.types }
  validates :parenty,   uri: { allow_nil: true }, owned: true
  validates :locations, uri: true, owned: true
  validates :devices,   uri: true, owned: true

  before_save :set_parent_id, :set_device_ids
  #after_save  :set_location_ids
  #before_update :move_children_to_root

  def resource_owner_id=(resource_owner_id)
    write_attribute(:resource_owner_id, resource_owner_id.to_s)
  end

  def children_devices
    children.map(&:devices).flatten
  end

  def descendants_devices
    descendants.map(&:devices).flatten
  end

  private

  def move_children_to_root
    children.each { |child| child.move_to_root } if locations
  end


  #def find_location(uri)
    #id = find_id(uri)
    #Location.where(id: id).where(resource_owner_id: resource_owner_id).first
  #end

  #def find_locations(uris)
    #ids = find_ids(uris)
    #Location.where(id: ids).where(resource_owner_id: resource_owner_id)
  #end

  def set_parent_id
    self.parent_id = find_id(parenty) if parenty
  end

  #def set_location_ids
    #Location.in(id: find_ids(locations)).each { |l| l.update_attributes(parent_id: self.id) } if locations
  #end

  def set_device_ids
    self.devices = find_ids(devices) if devices
  end
end

