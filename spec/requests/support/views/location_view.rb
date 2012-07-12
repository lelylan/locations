module LocationsViewMethods

  def should_have_owned_location(location)
    location = LocationDecorator.decorate(location)
    json = JSON.parse(page.source)
    should_contain_location(location)
    should_not_have_not_owned_locations
  end

  def should_contain_location(location)
    location = LocationDecorator.decorate(location)
    json = JSON.parse(page.source).first
    should_have_location(location, json)
  end

  def should_have_location(location, json = nil)
    location = LocationDecorator.decorate(location)
    should_have_valid_json
    json = JSON.parse(page.source) unless json 
    json = Hashie::Mash.new json
    json.uri.should == location.uri
    json.id.should == location.id.as_json
    json.name.should == location.name

    #parent = LocationDecorator.decorate(location.parent).uri
    #json.contained_in.parent.uri.should == parent.uri
    #json.contained_in.ancestors.each_with_index do |json_property, i|
      #should_have_property(location.ancestors[i], json_property)
    #end
  end

  def should_not_have_not_owned_locations
    should_have_valid_json
    json = JSON.parse(page.source)
    json.should have(1).item
    Location.all.should have(2).items
  end

end

RSpec.configuration.include LocationsViewMethods
