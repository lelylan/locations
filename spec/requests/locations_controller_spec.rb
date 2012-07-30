require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'LocationsController' do

  before { Location.delete_all }

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, resource_owner_id: user.id.to_s }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

  #describe 'GET /locations' do

    #let!(:resource)  { FactoryGirl.create :root, resource_owner_id: user.id.to_s }
    #let!(:not_owned) { FactoryGirl.create :root }
    #let(:uri)        { '/locations' }

    #it 'shows all owned resources' do
      #page.driver.get uri
      #page.status_code.should == 200
      #contains_owned_location resource
    #end

    #it_behaves_like 'searchable', { name: 'My name is resource', type: 'room' }

    #it_behaves_like 'paginable'
  #end

  context 'GET /locations/:id' do

    let!(:resource)  { LocationDecorator.decorate FactoryGirl.create(:floor, :with_ancestors, :with_descendants, :with_devices, resource_owner_id: user.id.to_s) }
    let!(:not_owned) { LocationDecorator.decorate FactoryGirl.create(:floor) }
    let(:uri)        { "/locations/#{resource.id}" }

    it 'view the owned resource' do
      page.driver.get uri
      page.status_code.should == 200
      has_location resource
    end

    it 'creates the resource connections' do
      resource.the_parent.should_not == nil
      resource.ancestors.should      have(2).itmes
      resource.children.should       have(1).item
      resource.descendants.should    have(2).items
    end

    it_behaves_like 'changeable host'
    it_behaves_like 'not found resource', 'page.driver.get(uri)'
  end

  #context 'POST /locations' do

    #let!(:uri) { '/locations' }
    #before     { page.driver.get uri } # let us use the decorators before calling the POST method

    #let(:parent) { FactoryGirl.create(:house, resource_owner_id: user.id.to_s) }
    #let(:child)  { FactoryGirl.create(:room, resource_owner_id: user.id.to_s) }
    #let(:device) { FactoryGirl.create(:device, resource_owner_id: user.id) }

    #let(:params) {{
      #name:      'New floor',
      #type:      'floor',
      #parent:    LocationDecorator.decorate(parent).uri, 
      #locations: [ LocationDecorator.decorate(child).uri ],
      #devices:   [ DeviceDecorator.decorate(device).uri ]
    #}}

    #before         { page.driver.post uri, params.to_json }
    #let(:resource) { Location.last }

    #it 'creates the resource' do
      #page.driver.post uri, params.to_json
      #resource = Location.last
      #page.status_code.should == 201
      #has_location resource
    #end

    #it 'creates the resource connections' do
      #resource.the_parent.should_not == nil
      #resource.ancestors.should      have(1).itmes
      #resource.children.should       have(1).item
      #resource.descendants.should    have(1).items
    #end

    #it 'stores the resource' do
      #expect { page.driver.post(uri, params.to_json) }.to change { Location.count }.by(1)
    #end

    #it_behaves_like 'check valid params',   'page.driver.post(uri, {}.to_json)', { method: 'POST', error: "Name can't be blank" }
    #it_behaves_like 'not valid json input', 'page.driver.post(uri, params.to_json)', { method: 'POST' }
  #end

  #context 'PUT /locations/:id' do

    #before { page.driver.get '/locations' } # let us use the decorators before calling the POST method

    #let!(:resource)  { FactoryGirl.create :floor, :with_parent, :with_children, resource_owner_id: user.id.to_s }
    #let!(:new_house) { FactoryGirl.create :house, name: 'New house', resource_owner_id: user.id.to_s }
    #let!(:new_room)  { FactoryGirl.create :room, name: 'New Room', resource_owner_id: user.id.to_s }

    #let(:uri) { "/locations/#{resource.id}" }

    #let(:params) {{
      #name:      'New floor', 
      #parent:    LocationDecorator.decorate(new_house).uri, 
      #locations: [LocationDecorator.decorate(new_room).uri] 
    #}}

    #before { page.driver.put uri, params.to_json }
    #before { resource.reload }

    #it 'updates the resource' do
      #page.status_code.should == 200
      #page.should have_content 'New'
      #has_location resource
    #end

    #it 'updates the resource connections' do
      #resource.the_parent.should     == new_house.reload
      #resource.children.first.should == new_room.reload
    #end

    #it_behaves_like 'a rescued 404 resource', 'page.driver.put(uri)', 'locations'
    #it_behaves_like 'not valid json input',   'page.driver.put(uri, params.to_json)', { method: 'PUT' }
  #end

  #context 'DELETE /locations/:id' do
    #let!(:resource) { FactoryGirl.create :floor, :with_ancestors, :with_descendants, resource_owner_id: user.id.to_s }
    #let(:uri)       { "/locations/#{resource.id}" }

    #scenario 'delete resource' do
      #expect { page.driver.delete(uri) }.to change{ Location.count }.by(-1)
      #page.status_code.should == 200
      #has_location resource
    #end

    #it_behaves_like 'a rescued 404 resource', 'page.driver.delete(uri)', 'locations'
  #end
end
