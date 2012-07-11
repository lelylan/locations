require 'addressable/uri'

class Location < ActiveRecord::Base
  acts_as_nested_set

  serialize :devices, Array

  attr_accessor :parent_uri
  attr_accessible :name, :parent_uri

  validates :name, presence: true
  validates :parent_uri, :url => {:allow_nil => true}

end
