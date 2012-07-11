object LocationDecorator.decorate(@location)

attributes :uri, :id, :name, :created_at, :updated_at

node(:contained) do |location|
  {
    parent: location.parent_view,
    ancestors: location.ancestors_view
  }
end

node(:contains) do |location|
  {
    children: location.children_view,
    descendants: location.descendants_view
  }
end

node(:devices) do |location|
  {
    children: location.device_children_view,
    descendants: location.device_descendants_view
  }
end
