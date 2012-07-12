require 'addressable/uri'

class Location < ActiveRecord::Base
  acts_as_nested_set

  # in this way we can use parent as attribute for the assignment
  alias_method :the_parent, :parent 

  serialize :devices, Array

  attr_accessor :parent, :locations
  attr_accessible :name, :devices, :parent, :locations

  validates :name, presence: true
  validates :parent, url: { allow_nil: true }
  #validates :location, array_url: true

  before_save :find_parent, :find_children


  private

    def find_parent
      if parent
        new_parent = find_location(parent.uri)
        self.move_to_child_of(new_parent) if new_parent
      end
    end

    def find_children
      if locations
        unless locations.empty?
          children = find_locations(locations)
          children.each { |child| child.move_to_child_of(self) }
        end
      end
    end

    def find_location(uri)
      id = find_id(uri)
      Location.where(id: id).where(created_from: current_user.uri).first
    end

    def find_locations(uris)
      ids = find_ids(uris)
      Location.where(id: ids).where(created_from: current_user.uri)
    end

end
