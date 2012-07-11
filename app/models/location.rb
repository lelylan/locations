require 'addressable/uri'

class Location < ActiveRecord::Base
  acts_as_nested_set, dependent: :leave_children

  attr_accessor :parent_uri
  attr_accessible :name, :parent_uri

  validates :name, presence: true
  validates :parent_uri, :url => {:allow_nil => true}

  before_save :parse_parent_uri


  private

    def parse_parent_uri
      self.parent_id = Addressable::URI.parse(parent_uri).basename if parent_uri
    end
end
