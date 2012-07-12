Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :location, aliases: ['house', 'root'] do
    name 'House'
    created_from Settings.user.uri

    factory 'Floor' do
      name 'Floor'
    end

    factory 'Room' do
      name 'Room'
    end

    factory :location_not_owned do
      created_from Settings.user.another.uri
    end
  end

  trait :with_parent do
    after(:create) do |floor|
      house = FactoryGirl.create :house
      floor.move_to_child_of house
    end
  end

  trait :with_ancestors do
    after(:create) do |floor|
      house = FactoryGirl.create :house
      floor.move_to_child_of house
      complex = FactoryGirl.create :house, name: "Complex of houses"
      house.move_to_child_of complex
    end
  end

  trait :with_children do
    after(:create) do |floor|
      room = FactoryGirl.create :room
      room.move_to_child_of floor
    end
  end

  trait :with_descendants do
    after(:create) do |floor|
      room = FactoryGirl.create :room
      room.move_to_child_of floor
      mini = FactoryGirl.create :room, name: "Bosone", devices: [ { uri: Settings.device.descendants.uri } ]
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
