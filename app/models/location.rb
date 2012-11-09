class Location
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Ancestry
  include Resourceable

  field :resource_owner_id, type: Moped::BSON::ObjectId
  field :name
  field :type
  field :device_ids, type: Array, default: []

  index({ resource_owner_id: 1 }, { background: true })
  index({ type: 1 }, { background: true })
  index({ name: 1 }, { background: true })
  index({ device_ids: 1 }, { background: true })

  attr_accessor  :into, :locations, :devices
  attr_protected :resource_owner_id, :location_ids, :device_ids

  has_ancestry orphan_strategy: :rootify

  validates :resource_owner_id, presence: true
  validates :name, presence: true
  validates :type, presence: true, inclusion: { in: Settings.locations.types }
  validates :into,      uri: { allow_nil: true }, owned: true
  validates :locations, uri: true, owned: true
  validates :devices,   uri: true, owned: true

  before_save   :set_parent_id, :set_device_ids
  after_save    :set_location_ids
  before_update :move_children_to_root

  def children_devices
    children.map(&:device_ids).flatten
  end

  def descendants_devices
    descendants.map(&:device_ids).flatten
  end

  private

  def set_parent_id
    self.parent_id = find_id(into) if into
  end

  def set_location_ids
    Location.in(id: find_ids(locations)).each { |l| l.update_attributes(parent_id: self.id) } if locations
  end

  def set_device_ids
    self.device_ids = find_ids(devices).map{|id| Moped::BSON::ObjectId(id) } if devices
  end

  def move_children_to_root
    children.each { |l| l.update_attributes(parent_id: nil) } if locations
  end
end
