collection LocationDecorator.decorate(@descendants_locations)

attributes :uri, :name
node(:id)      { |l| l.id.to_s }
node(:parent)  { |l| l.parent_view }
node(:devices) { |l| l.devices_view }
