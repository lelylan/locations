object LocationDecorator.decorate(@location)

node(:uri)        { |l| l.uri }
node(:id)         { |l| l.id.to_s }
node(:name)       { |l| l.name }
node(:type)       { |l| l.type.downcase }
node(:created_at) { |l| l.created_at }
node(:updated_at) { |l| l.updated_at }

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

