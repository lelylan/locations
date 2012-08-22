require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'DescendantsController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'locations' }
  let(:factory)    { 'root' }

  describe 'GET /locations/:id/descendants' do

    let!(:child_device)      { FactoryGirl.create :device, name: 'Child light', resource_owner_id: user.id }
    let!(:descendant_device) { FactoryGirl.create :device, name: 'Descendant light', resource_owner_id: user.id }

    let!(:complex) { FactoryGirl.create(:house, name: 'House agglomerate', resource_owner_id: user.id) }
    let!(:house)   { FactoryGirl.create(:house, parent_id: complex.id, resource_owner_id: user.id) }
    let!(:floor)   { FactoryGirl.create(:floor, parent_id: house.id, resource_owner_id: user.id) }
    let!(:room)    { FactoryGirl.create(:room, parent_id: floor.id, devices: [a_uri(child_device)], resource_owner_id: user.id) }
    let!(:mini)    { FactoryGirl.create(:room, parent_id: room.id, devices: [a_uri(descendant_device)], name: 'Barbie room', resource_owner_id: user.id) }

    let!(:resource) { floor }
    let(:uri)       { "/locations/#{resource.id}/descendants" }

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
      json.last['devices'].should have(1).item
    end

    it_behaves_like 'a changeable host'
    it_behaves_like 'a not owned resource', 'page.driver.get(uri)'
    it_behaves_like 'a not found resource', 'page.driver.get(uri)'
  end
end
