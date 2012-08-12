require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'DescendantsController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'write', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'locations' }
  let(:factory)    { 'root' }

  describe 'GET /locations/:id/descendants' do

    let!(:resource)  { FactoryGirl.create(:floor, :with_ancestors, :with_descendants, :with_devices, resource_owner_id: user.id) }
    let(:uri)        { "/locations/#{resource.id}/descendants" }

    it 'view the descendants resources' do
      page.driver.get uri
      page.status_code.should == 200
      has_descendants resource
    end

    it 'contains the resource connections' do
      page.driver.get uri
      json = JSON.parse page.source
      json.should have(2).itmes
      json.first['devices'].should have(1).item
    end

    it_behaves_like 'a changeable host'
    it_behaves_like 'a not found resource', 'page.driver.get(uri)'
  end
end
