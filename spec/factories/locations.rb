# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location, aliases: ['root'] do
    name 'Root'
    created_from Settings.user.uri

    factory :location_not_owned do
      created_from Settings.user.another.uri
    end
  end

end
