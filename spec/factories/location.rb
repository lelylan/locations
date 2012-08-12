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
      floor.move_to_child_of house
    end
  end

  trait :with_ancestors do
    after(:create) do |floor|
      house = FactoryGirl.create :house, resource_owner_id: floor.resource_owner_id
      floor.move_to_child_of house
      complex = FactoryGirl.create :house, name: 'Complex of houses', resource_owner_id: floor.resource_owner_id
      house.move_to_child_of complex
    end
  end

  trait :with_children do
    after(:create) do |floor|
      room = FactoryGirl.create :room, resource_owner_id: floor.resource_owner_id
      room.move_to_child_of floor
    end
  end

  trait :with_descendants do
    after(:create) do |floor|
      room = FactoryGirl.create :room, resource_owner_id: floor.resource_owner_id
      room.move_to_child_of floor
      mini = FactoryGirl.create :room, name: 'Bosone', resource_owner_id: floor.resource_owner_id
      mini.move_to_child_of room
    end
  end

  trait :with_devices do
    after(:create) do |floor|
      device_house = FactoryGirl.create :device, name: 'Light house', resource_owner_id: floor.resource_owner_id
      floor.the_parent.update_attributes devices: [ a_uri(device_house) ]

      device_floor = FactoryGirl.create :device, name: 'Light floor', resource_owner_id: floor.resource_owner_id
      floor.update_attributes devices: [ a_uri(device_floor) ]

      device_room = FactoryGirl.create :device, name: 'Light room', resource_owner_id: floor.resource_owner_id
      floor.children.first.update_attributes devices: [ a_uri(device_room) ]
    end
  end
end
