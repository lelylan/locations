class DeviceDecorator < ApplicationDecorator
  decorates :Device

  def uri
    "#{h.request.protocol}#{devices_host}/devices/#{model.id}"
  end
end
