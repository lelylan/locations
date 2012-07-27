Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :location, aliases: ['house', 'root'] do
    name 'House'
    type 'house'
    resource_owner_id Settings.user.id

    factory 'Floor' do
      name 'Floor'
      type 'floor'
    end

    factory 'Room' do
      name 'Room'
      type 'room'
    end

    factory :location_not_owned do
      resource_owner_id Settings.user.another.id
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
      complex = FactoryGirl.create :house, name: "Complex of houses", resource_owner_id: floor.resource_owner_id
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
      mini = FactoryGirl.create :room, name: "Bosone", devices: [ { uri: Settings.device.descendants.uri } ], resource_owner_id: floor.resource_owner_id
      mini.move_to_child_of room
    end
  end

  trait :with_children_devices do
    before(:create) do |location|
      location.devices = [
        { uri: Settings.device.uri },
        { uri: Settings.device.another.uri }
      ]
    end
  end

  trait :with_devices do
    after(:create) do |location|
      location.devices = [ { uri: Settings.device.uri }, { uri: Settings.device.another.uri } ]
      location.save
    end
  end
end
