module LocationsViewMethods

  def contains_owned_location(location)
    location = LocationDecorator.decorate location
    json     = JSON.parse page.source
    contains_location location
    has_not_not_owned_locations
  end

  def contains_location(location)
    location = LocationDecorator.decorate location
    json     = JSON.parse(page.source).first
    has_location location, json
  end

  def has_location(location, json = nil)
    has_valid_json

    location = LocationDecorator.decorate location
    json     = JSON.parse page.source unless json 
    json     = Hashie::Mash.new json

    json.uri.should  == location.uri
    json.id.should   == location.id.to_s
    json.name.should == location.name
    json.type.should == location.type
    json.created_at.should_not be_nil
    json.updated_at.should_not be_nil

    if not Location.where(id: location.id).count == 0 # avoid problems when resource is deleted
      has_parent json, location
      has_ancestors json, location
      has_locations json, location
    end
  end

  def has_parent(json, location)
    if location.the_parent
      parent = LocationDecorator.decorate(location.the_parent)
      json.parent.uri.should  == parent.uri
      json.parent.name.should == parent.name
      json.parent.id.should   == parent.id.to_s
    else
      json.parent.should == nil
    end
  end

  def has_ancestors(json, location)
    ancestors = LocationDecorator.decorate(location.ancestors)
    json.ancestors.each_with_index do |json_ancestor, i|
      json_ancestor.uri.should  == ancestors[i].uri
      json_ancestor.name.should == ancestors[i].name
      json_ancestor.id.should   == ancestors[i].id.to_s
    end
  end

  def has_locations(json, location)
    locations = LocationDecorator.decorate(location.children)
    json.locations.each_with_index do |json_child, i|
      json_child.uri.should  == locations[i].uri
      json_child.name.should == locations[i].name
      json_child.id.should   == locations[i].id.to_s
    end
  end

  def has_devices(json, location)
    devices = Device.in(id: location.devices.map {|id| Moped::BSON::ObjectId(id)} )
    json.locations.each_with_index do |json_child, i|
      json_child.uri.should  == devices[i].uri
      json_child.name.should == devices[i].name
      json_child.id.should   == devices[i].id.to_s
    end
  end

  def has_not_not_owned_locations
    has_valid_json
    json = JSON.parse(page.source)
    json.should have(1).item
    Location.all.should have(2).items
  end

end

RSpec.configuration.include LocationsViewMethods
