require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

shared_examples_for 'searchable' do |searchable|

  searchable.each do |key, value|

    describe "?#{key}={#{key}}" do

      let!(:result) { FactoryGirl.create :location, key => value, resource_owner_id: user.id.to_s }

      it 'returns the searched location' do
        page.driver.get uri, {key => value}.merge(token)
        contains_location result
        page.should_not have_content resource[key]
      end
    end
  end
end

