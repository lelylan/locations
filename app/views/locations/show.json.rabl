object LocationDecorator.decorate(@location)

attributes :uri, :id, :name, :created_at, :updated_at

node(:locations) do |location|
  {
    parent: location.parent_view,
    children: location.children_view,
    ancestors: location.ancestors_view,
    descendants: location.descendants_view
  }
end

node(:devices) do |location|
  {
    children: location.device_children_view,
    descendants: location.device_descendants_view
  }
end
