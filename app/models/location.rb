class Location < ActiveRecord::Base
  include Lelylan::Search::URI

  acts_as_nested_set

  alias_method :the_parent, :parent # use parent as attribute for the mass assignment

  self.inheritance_column = :_type_disabled

  serialize :devices, Array

  attr_accessor   :parent, :locations
  attr_accessible :name, :devices, :parent, :locations, :type

  validates :name, presence: true
  validates :type, presence: true, inclusion: { in: Settings.locations.types }
  validates :parent, uri: { allow_nil: true }, owned: true
  validates :locations, uri: true, owned: true
  validates :devices, uri: true, owned: true

  before_update :move_children_to_root
  before_save   :set_device_ids
  after_save    :find_parent, :find_children

  def children_devices
    children.map(&:devices).flatten
  end

  def descendants_devices
    descendants.map(&:devices).flatten
  end

  def move_children_to_root
    children.each { |child| child.move_to_root } if locations
  end

  private

  def find_parent
    if parent
      new_parent = find_location(parent)
      self.move_to_child_of(new_parent) if new_parent
    end
  end

  def find_children
    if locations and !locations.empty?
      children = find_locations(locations)
      children.each { |child| child.move_to_child_of(self) }
    end
  end

  def find_location(uri)
    id = find_id(uri)
    Location.where(id: id).where(resource_owner_id: resource_owner_id).first
  end

  def find_locations(uris)
    ids = find_ids(uris)
    Location.where(id: ids).where(resource_owner_id: resource_owner_id)
  end

  def set_device_ids
    self.devices = find_ids(devices)
  end
end

