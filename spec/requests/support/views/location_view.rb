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
    json.public.should == location.public

    properties = Property.in(_id: location.property_ids)
    json.properties.each_with_index do |json_property, index|
      should_have_property(properties[index], json_property)
    end

    functions = Function.in(_id: location.function_ids)
    json.functions.each_with_index do |json_function, index|
      should_have_function(functions[index], json_function)
    end

    statuses = Status.in(_id: location.status_ids)
    json.statuses.each_with_index do |json_status, index|
      should_have_status(statuses[index], json_status)
    end

    categories = Category.in(_id: location.category_ids)
    json.categories.each_with_index do |json_category, index|
      should_have_category(categories[index], json_category)
    end
  end

  def should_not_have_not_owned_locations
    should_have_valid_json
    json = JSON.parse(page.source)
    json.should have(1).item
    Location.all.should have(2).items
  end

end

RSpec.configuration.include LocationsViewMethods
