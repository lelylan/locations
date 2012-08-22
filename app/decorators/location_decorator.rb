class LocationDecorator < ApplicationDecorator
  decorates :Location

  def uri
    h.location_path(model, default_options)
  end

  def parent_view
    model.parent ? format_location(model.parent) : nil
  end

  def ancestors_view
    model.ancestors.map do |location|
      format_location(location)
    end
  end

  def locations_view
    model.children.map do |location|
      format_location(location)
    end
  end

  # TODO to improve making just one query (use something like identity map)
  # on descendants views as we make a query for every locations
  def devices_view
    devices = Device.in(id: model.device_ids )
    devices.map { |device| format_device(device) }
  end

  private

  def format_location(location)
    { 
      uri: LocationDecorator.decorate(location).uri,
      id: location.id.to_s,
      name: location.name
    }
  end

  def format_device(device)
    { 
      uri: DeviceDecorator.decorate(device).uri,
      id: device.id.to_s,
      name: device.name
    }
  end
end
