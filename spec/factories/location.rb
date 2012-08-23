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

  trait :with_children do
    after(:create) do |floor|
      room = FactoryGirl.create :room, resource_owner_id: floor.resource_owner_id
      room.update_attributes parent_id: floor.id
    end
  end
end
