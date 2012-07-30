require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'LocationsController' do

  before { Location.delete_all }

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, resource_owner_id: user.id.to_s }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

  describe 'GET /locations' do

    let!(:resource)  { FactoryGirl.create :root, resource_owner_id: user.id.to_s }
    let!(:not_owned) { FactoryGirl.create :root }

    let(:uri) { '/locations' }

    it 'shows all owned resources' do
      page.driver.get uri
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
      page.driver.get uri
      page.status_code.should == 200
      has_location resource
    end

    it_behaves_like 'changeable host'
  end

  context 'POST /locations' do

    let(:uri) { '/locations' }

    before { page.driver.get uri }

    let(:parent) { FactoryGirl.create(:house, resource_owner_id: user.id.to_s) }
    let(:child)  { FactoryGirl.create(:room, resource_owner_id: user.id.to_s) }
    let(:device) { FactoryGirl.create(:device, resource_owner_id: user.id.to_s) }

    let(:params) {{
      name:      'New floor',
      type:      'floor',
      parent:    LocationDecorator.decorate(parent).uri, 
      locations: [ LocationDecorator.decorate(child).uri ],
      devices:   [ DeviceDecorator.decorate(device).uri ]
    }}

    #it 'creates the resource' do
      #page.driver.post uri, params.to_json
      #resource = Location.last
      #page.status_code.should == 201
      #has_location resource
    #end

    #describe 'resource connections' do

      #before { page.driver.post uri, params.to_json }

      #let(:resources) { Location.last }

      #it 'creates the resource connections' do
        #print page.source
        #resource.the_parent.should_not == nil
        #resource.ancestors.should   have(2).itmes
        #resource.children.should    have(1).item
        #resource.descendants.should have(2).items
      #end
    #end

    #it 'stores the resource' do
      #expect{ page.driver.post(uri, params.to_json) }.to change{ Location.count }.by(1)
    #end

    #it_behaves_like 'check valid params',   'page.driver.post(uri, params.to_json)', { method: 'POST', error: 'Name can\'t be blank' }
    #it_behaves_like 'not valid json input', 'page.driver.post(uri, params.to_json)', { method: 'POST' }
  end
end



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
