Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :location, aliases: ['house', 'root'] do
    name 'House'
    type 'house'
    resource_owner_id '0000aaa0a000a00000000000'

    factory 'Floor' do
      name 'Floor'
      type 'floor'
    end

    factory 'Room' do
      name 'Room'
      type 'room'
    end
  end

  trait :with_parent do
    after(:create) do |floor|
      house = FactoryGirl.create :house, resource_owner_id: floor.resource_owner_id
      floor.update_attributes parent_id: house.id
    end
  end

  trait :with_ancestors do
    after(:create) do |floor|
      house = FactoryGirl.create :house, resource_owner_id: floor.resource_owner_id
      floor.update_attributes parent_id: house.id
      #complex = FactoryGirl.create :house, name: 'Complex of houses', resource_owner_id: floor.resource_owner_id
      #house.update_attributes parent_id: complex.id
    end
  end

  trait :with_children do
    after(:create) do |floor|
      room = FactoryGirl.create :room, resource_owner_id: floor.resource_owner_id
      room.update_attributes parent_id: floor.id
    end
  end

  trait :with_descendants do
    after(:create) do |floor|
      room = FactoryGirl.create :room, resource_owner_id: floor.resource_owner_id
      room.update_attributes parent_id: floor.id
      mini = FactoryGirl.create :room, name: 'Bosone', resource_owner_id: floor.resource_owner_id
      mini.update_attributes parent_id: room.id
      pp floor.children.entries
      pp floor.descendants.entries
    end
  end

  trait :with_devices do
    after(:create) do |floor|
      device_house = FactoryGirl.create :device, name: 'Light house', resource_owner_id: floor.resource_owner_id
      floor.parent.update_attributes devices: [ a_uri(device_house) ]

      device_floor = FactoryGirl.create :device, name: 'Light floor', resource_owner_id: floor.resource_owner_id
      floor.update_attributes devices: [ a_uri(device_floor) ]

      device_room = FactoryGirl.create :device, name: 'Light room', resource_owner_id: floor.resource_owner_id
      floor.children.first.update_attributes devices: [ a_uri(device_room) ]
    end
  end
end
