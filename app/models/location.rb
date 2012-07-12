class Location < ActiveRecord::Base
  include Lelylan::Search::URI

  acts_as_nested_set
  alias_method :the_parent, :parent # use parent as attribute for the mass assignment

  serialize :devices, Array

  attr_accessor :parent, :locations
  attr_accessible :name, :devices, :parent, :locations

  validates :name, presence: true
  validates :parent, uri: { allow_nil: true }, owned: true
  validates :locations, uri: true, owned: true

  after_save :find_parent, :find_children
  before_update :move_children_to_root

  def move_children_to_root
    children.each { |child| child.move_to_root } if locations
  end

  private

    # set the parent
    def find_parent
      if parent
        new_parent = find_location(parent)
        self.move_to_child_of(new_parent) if new_parent
      end
    end

    # set the children
    def find_children
      if locations and !locations.empty?
        children = find_locations(locations)
        children.each { |child| child.move_to_child_of(self) }
      end
    end

    # find a location given its URI
    def find_location(uri)
      id = find_id(uri)
      Location.where(id: id).where(created_from: created_from).first
    end

    # find locations given its URIs
    def find_locations(uris)
      ids = find_ids(uris)
      Location.where(id: ids).where(created_from: created_from)
    end
end

