module HelpersViewMethods
  def has_descendants(location, json = nil)
    has_valid_json
    descendants = LocationDecorator.decorate location.descendants
    json = JSON.parse page.source

    descendants.each_with_index do |descendant, i|
      descendant_json = Hashie::Mash.new(json[i])
      descendant_json.uri.should  == descendant.uri
      descendant_json.name.should == descendant.name
      descendant_json.id.should   == descendant.id.to_s

      has_descendant_parent(descendant.parent, descendant_json.parent)
      has_descendant_devices(descendant.device_ids, descendant_json.devices)
    end
  end

  def has_descendant_parent(parent, parent_json)
    parent = LocationDecorator.decorate parent
    parent_json.uri.should  == parent.uri
    parent_json.name.should == parent.name
    parent_json.id.should   == parent.id.to_s
  end

  def has_descendant_devices(device_ids, devices_json)
    devices = Device.in(id: device_ids)
    devices = DeviceDecorator.decorate devices
    devices.each_with_index do |device, i|
      devices_json[i].uri.should  == device.uri
      devices_json[i].name.should == device.name
      devices_json[i].id.should   == device.id.to_s
    end
  end
end

RSpec.configuration.include HelpersViewMethods
