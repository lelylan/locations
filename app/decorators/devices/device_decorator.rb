class DeviceDecorator < ApplicationDecorator
  decorates :Device

  def device_host
    host = h.params[:host] || 'http://devices.lelylan.com'
  end

  def uri
    "#{device_host}/devices/#{model.id}"
  end
end
