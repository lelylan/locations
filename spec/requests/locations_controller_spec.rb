require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'LocationsController' do


  before { Location.delete_all }

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, resource_owner_id: user.id }
  let!(:token)        { { access_token: access_token.token } }

  describe 'GET /locations' do

    let!(:resource)  { FactoryGirl.create :root, resource_owner_id: user.id.to_s }
    let!(:not_owned) { FactoryGirl.create :root }

    let(:uri) { '/locations' }

    it 'shows all owned resources' do
      page.driver.get uri, token
      page.status_code.should == 200
      contains_owned_location resource
    end

    it_behaves_like 'searchable', { name: 'My name is resource', type: 'room' }

    it_behaves_like 'paginable'
  end


  context 'GET /locations/:id' do

    let!(:resource) { LocationDecorator.decorate FactoryGirl.create(:floor, :with_ancestors, :with_descendants, :with_devices, resource_owner_id: user.id.to_s) }

    let(:uri) { "/locations/#{resource.id}" }

    it 'view the owned resource' do
      page.driver.get uri, token
      page.status_code.should == 200
      has_location resource
    end

    it_behaves_like 'changeable host'
  end
end



  ## ---------------
  ## POST /locations
  ## ---------------
  #context '.create' do

  #let(:uri) do
  #'/locations'
  #end

  #it_should_behave_like 'not authorized resource', 'page.driver.post(uri)'

  #context 'when logged in' do

  #before do
  #basic_auth
  #end

  #let!(:floor) do
  #LocationDecorator.decorate FactoryGirl.create(:floor, :with_ancestors, :with_descendants)
  #end

  #let(:params) do
  #{ 
  #name: 'Magic floor',
  #type: 'floor',
  #parent: LocationDecorator.decorate(floor.the_parent).uri, 
  #locations: [
  #LocationDecorator.decorate(floor.children.first).uri,
  #],
  #devices: [
  #Settings.device.uri,
  #Settings.device.another.uri
  #]
  #}
  #end

  #it 'creates the resource' do
  #page.driver.post uri, params.to_json
  #resource = Location.last
  #page.status_code.should == 201
  #should_have_location resource
  #end

  #it 'creates the resource connections' do
  #page.driver.post uri, params.to_json
  #resource = Location.last
  #resource.the_parent.should_not == nil
  #resource.ancestors.should have(2).itmes
  #resource.children.should have(1).item
  #resource.descendants.should have(2).items
  #end

  #it 'stores the resource' do
  #expect{ page.driver.post(uri, params.to_json) }.to change{ Location.count }.by(1)
  #end

  #it_validates 'not valid params', 'page.driver.post(uri, params.to_json)', { method: 'POST', error: 'Name can't be blank' }
  #it_validates 'not valid JSON', 'page.driver.post(uri, params.to_json)', { method: 'POST' }
  #end
  #end



  ## ---------------------
  ## PUT /locations/:id
  ## ---------------------
  #context '.update' do

  #let(:new_house) do
  #LocationDecorator.decorate FactoryGirl.create(:house, name: 'New house')
  #end

  #let(:new_room) do
  #LocationDecorator.decorate FactoryGirl.create(:room, name: 'New Room')
  #end

  #let(:resource) do
  #FactoryGirl.create :floor, :with_parent, :with_children
  #end

  #let(:old_house) do
  #resource.the_parent
  #end

  #let(:old_room) do
  #resource.children.first
  #end

  #let(:resource_not_owned) do
  #FactoryGirl.create :location_not_owned
  #end

  #let(:uri) do
  #'/locations/#{resource.id}'
  #end

  #it_should_behave_like 'not authorized resource', 'page.driver.put(uri)'

  #context 'when logged in' do

  #before do
  #basic_auth
  #end

  #let(:params) do
  #{
  #name: 'New floor', 
  #parent: '#{host}/locations/#{new_house.id}', 
  #locations: ['#{host}/locations/#{new_room.id}'] 
  #}
  #end

  #context 'when updating' do

  #before do
  #page.driver.put uri, params.to_json
  #resource.reload
  #end

  #it 'shows the updated resource' do
  #page.status_code.should == 200
  #page.should have_content 'New'
  #should_have_location resource
  #end

  #it 'updates parent' do
  #resource.the_parent.should == new_house.reload
  #end

  #it 'updates children' do
  #resource.children.first.should == new_room.reload
  #end
  #end

  #it_should_behave_like 'a rescued 404 resource', 'page.driver.put(uri)', 'locations'
  #it_validates 'not valid JSON', 'page.driver.put(uri, params.to_json)', { method: 'PUT' }
  #end
  #end



  ## ------------------------
  ## DELETE /locations/:id
  ## ------------------------
  #context '.destroy' do

  #let!(:resource) do
  #FactoryGirl.create(:floor, :with_ancestors, :with_descendants)
  #end

  #let(:uri) do
  #'/locations/#{resource.id}'
  #end

  #let(:resource_not_owned) do
  #FactoryGirl.create(:location_not_owned)
  #end

  #it_should_behave_like 'not authorized resource', 'page.driver.delete(uri)'

  #context 'when logged in' do

  #before do
  #basic_auth
  #end

  #scenario 'delete resource' do
  #expect{ page.driver.delete(uri) }.to change{ Location.count }.by(-1)
  #page.status_code.should == 200
  #should_have_location resource
  #end

  #it_should_behave_like 'a rescued 404 resource', 'page.driver.delete(uri)', 'locations'
  #end
