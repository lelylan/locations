class LocationSerializer < ApplicationSerializer
  cached true

  attributes :uri, :id, :name, :type, :parent, :ancestors, :locations, :devices,
             :created_at, :updated_at

  def uri
    LocationDecorator.decorate(object).uri
  end

  def parent
    LocationDecorator.decorate(object).parent_view
  end

  def ancestors
    LocationDecorator.decorate(object).ancestors_view
  end

  def locations
    LocationDecorator.decorate(object).locations_view
  end

  def devices
    LocationDecorator.decorate(object).devices_view
  end
end
