object LocationDecorator.decorate(@location)

attributes :uri, :name, :type, :created_at, :updated_at

node(:id)        { |l| l.id.to_s }
node(:parent)    { |l| l.parent_view }
node(:ancestors) { |l| l.ancestors_view }
node(:locations) { |l| l.locations_view }
node(:devices)   { |l| l.devices_view }
