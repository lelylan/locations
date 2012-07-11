class LocationDecorator < ApplicationDecorator
  decorates :Location

  def uri
    h.location_path(model, default_options)
  end
end
