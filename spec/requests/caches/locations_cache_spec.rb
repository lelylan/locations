require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature 'Caching' do

  before { ActionController::Base.perform_caching = true }
  before { Rails.cache.clear }
  after  { ActionController::Base.perform_caching = false }

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-location', 'application/json' }

  let(:controller) { 'locations' }
  let(:factory)    { 'location' }

  describe 'GET /locations/:id' do

    let!(:resource) { FactoryGirl.create :location, resource_owner_id: user.id }
    let(:uri)       { "/locations/#{resource.id}" }
    let(:cache_key) { ActiveSupport::Cache.expand_cache_key(['location_serializer', resource.cache_key, 'to-json']) }

    before { page.driver.get uri }

    describe 'with fragment caching' do

      it 'creates the fragment cache' do
        Rails.cache.exist?(cache_key).should be_true
      end

      it 'saves the JSON resource into the cache' do
        cached = JSON.parse Rails.cache.read(cache_key)
        has_resource resource, cached
      end
    end

    describe 'with HTTP caching' do

      describe 'when sends the If-Modified-Since header' do

        describe 'when the resource does not change' do

          before { page.driver.header 'If-Modified-Since', resource.updated_at.httpdate }
          before { page.driver.get uri }

          it 'returns a not modified response' do
            page.status_code.should == 304
          end
        end

        describe 'when the resource changes' do

          let!(:timestamp) { resource.updated_at }

          before { resource.updated_at = resource.updated_at + 1; resource.save }
          before { page.driver.header 'If-Modified-Since', (timestamp).httpdate }
          before { page.driver.get uri }

          it 'executes the action' do
            page.status_code.should == 200
          end

          it 'creates a new fragment cache' do
            new_key = ActiveSupport::Cache.expand_cache_key(['location_serializer', resource.cache_key, 'to-json'])
            Rails.cache.exist?(new_key).should be_true
          end

          it 'returns the Last-Modified header' do
            page.response_headers['Last-Modified'].should == resource.updated_at.httpdate
          end
        end
      end

      describe 'when sends the If-None-Match header' do

        let(:etag) { page.response_headers['ETag'] }

        describe 'when the resource does not change' do

          before { page.driver.header 'If-None-Match', etag }
          before { page.driver.get uri }

          it 'returns a not modified response' do
            page.status_code.should == 304
          end
        end

        describe 'when the resource changes' do

          before { resource.updated_at = resource.updated_at + 1; resource.save }
          before { page.driver.header 'If-None-Match', etag }
          before { page.driver.get uri }

          it 'executes the action' do
            page.status_code.should == 200
          end

          it 'creates a new fragment cache' do
            new_key = ActiveSupport::Cache.expand_cache_key(['location_serializer', resource.cache_key, 'to-json'])
            Rails.cache.exist?(new_key).should be_true
          end

          it 'returns the ETag header' do
            page.response_headers['ETag'].should_not == etag
          end
        end
      end
    end
  end

  describe 'GET /locations' do

    let!(:resource) { FactoryGirl.create :location, resource_owner_id: user.id }
    let(:uri)       { "/locations" }

    let(:cache_json_key) { ActiveSupport::Cache.expand_cache_key(['location_serializer', resource.cache_key, 'to-json']) }
    let(:cache_hash_key) { ActiveSupport::Cache.expand_cache_key(['location_serializer', resource.cache_key, 'serializable-hash']) }

    before { page.driver.get uri }

    describe 'with fragment caching' do

      it 'does not create the json fragment cache' do
        Rails.cache.exist?(cache_json_key).should_not be_true
      end

      it 'creates the serialized hash fragment cache' do
        Rails.cache.exist?(cache_hash_key).should be_true
      end
    end
  end

  describe 'when a location is already cached' do

    let!(:resource) { FactoryGirl.create :location, :with_parent, :with_children, resource_owner_id: user.id }
    before          { resource.update_attributes(updated_at: Time.now - 60) }
    let!(:uri)      { "/locations/#{resource.id}" }
    let!(:old_key)  { ActiveSupport::Cache.expand_cache_key(['location_serializer', resource.cache_key, 'to-json']) }

    describe 'when a child is updated' do

      describe 'with a new name' do

        let!(:connection) { resource.descendants.first.update_attributes(name: 'updated') }
        let!(:new_key)    { ActiveSupport::Cache.expand_cache_key(['location_serializer', resource.reload.cache_key, 'to-json']) }

        describe 'GET /locations/:id' do

          before { page.driver.get uri }

          it 'refresh the fragment cache' do
            Rails.cache.exist?(new_key).should be_true
          end

          it 'creates a new cache key' do
            new_key.should_not == old_key
          end
        end
      end

      describe 'with anything but not the name' do

        let!(:connection) { resource.descendants.first.save }
        let!(:new_key)    { ActiveSupport::Cache.expand_cache_key(['location_serializer', resource.reload.cache_key, 'to-json']) }

        describe 'GET /locations/:id' do

          before { page.driver.get uri }

          it 'does not create a new cache key' do
            new_key.should == old_key
          end
        end
      end
    end

    describe 'when a parent is updated' do

      describe 'with a new name' do

        let!(:connection) { resource.ancestors.first.update_attributes(name: 'updated') }
        let!(:new_key)    { ActiveSupport::Cache.expand_cache_key(['location_serializer', resource.reload.cache_key, 'to-json']) }

        describe 'GET /locations/:id' do

          before { page.driver.get uri }

          it 'refresh the fragment cache' do
            Rails.cache.exist?(new_key).should be_true
          end

          it 'creates a new cache key' do
            new_key.should_not == old_key
          end
        end
      end

      describe 'with anything but not the name' do

        let!(:connection) { resource.ancestors.first.save }
        let!(:new_key)    { ActiveSupport::Cache.expand_cache_key(['location_serializer', resource.reload.cache_key, 'to-json']) }

        describe 'GET /locations/:id' do

          before { page.driver.get uri }

          it 'does not create a new cache key' do
            new_key.should == old_key
          end
        end
      end
    end
  end
end

