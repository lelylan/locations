class LocationDecorator < ApplicationDecorator
  decorates :Location

  def uri
    h.location_path(model, default_options)
  end

  def parent_view
    model.parent ? format_resource(model.parent) : nil
  end

  def ancestors_view
    model.ancestors.map do |location|
      format_resource(location)
    end
  end

  def children_view
    model.children.map do |location|
      format_resource(location)
    end
  end

  def descendants_view
    model.descendants.map do |location|
      format_resource(location)
    end
  end

  def device_children_view
    model.devices.map do |device|
      { uri: device[:uri] } 
    end
  end

  def device_descendants_view
    model.descendants.map do |location|
      location.devices.map do |device|
        { uri: device[:uri] }
      end
    end.flatten
  end

  private

    def format_resource(location)
      { uri: LocationDecorator.decorate(location).uri }
    end
end
