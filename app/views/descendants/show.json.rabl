collection LocationDecorator.decorate(@descendants_locations)

attributes :uri, :id, :name
node(:parent)  { |l| l.parent_view }
node(:devices) { |l| l.devices_view }
