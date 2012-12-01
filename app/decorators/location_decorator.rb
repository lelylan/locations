class LocationDecorator < ApplicationDecorator
  decorates :location

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
