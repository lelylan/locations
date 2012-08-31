require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'LocationsController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'locations' }
  let(:factory)    { 'root' }

  describe 'GET /locations' do

    let!(:resource) { FactoryGirl.create :root, resource_owner_id: user.id }
    let(:uri)       { '/locations' }

    it_behaves_like 'a listable resource'
    it_behaves_like 'a paginable resource'
    it_behaves_like 'a searchable resource', { name: 'My name is resource', type: 'room' }
  end

  context 'GET /locations/:id' do

    let!(:resource) { FactoryGirl.create :root, resource_owner_id: user.id }
    let(:uri)       { "/locations/#{resource.id}" }

    it_behaves_like 'a showable resource'
    it_behaves_like 'a proxiable service'
    it_behaves_like 'a not owned resource', 'page.driver.get(uri)'
    it_behaves_like 'a not found resource', 'page.driver.get(uri)'
  end

  context 'POST /locations' do

    let(:uri) { '/locations' }
    before    { page.driver.get uri } # let us use the decorators before calling the POST method

    let!(:parent) { FactoryGirl.create(:house, resource_owner_id: user.id) }
    let!(:child)  { FactoryGirl.create(:room, resource_owner_id: user.id) }
    let!(:device) { FactoryGirl.create(:device, resource_owner_id: user.id) }

    let(:params) {{ 
      name:      'New floor', 
      type:      'floor', 
      into:      a_uri(parent), 
      locations: [ a_uri(child) ], 
      devices:   [ a_uri(device) ] 
    }}

    context 'when creates the connections' do

      before     { page.driver.post uri, params.to_json }
      let(:json) { Hashie::Mash.new JSON.parse(page.source) }

      it 'shows the connections' do
        json.parent.should_not == nil
        json.locations.should have(1).itmes
        json.devices.should have(1).item
      end
    end

    it_behaves_like 'a creatable resource'
    it_behaves_like 'a validated resource', 'page.driver.post(uri, {}.to_json)', { method: 'POST', error: 'can\'t be blank' }
  end

  context 'PUT /locations/:id' do

    before { page.driver.get '/locations' } # let us use the decorators before calling the POST method

    let!(:resource)  { FactoryGirl.create :floor, :with_parent, :with_children, resource_owner_id: user.id }
    let!(:new_house) { FactoryGirl.create :house, name: 'New house', resource_owner_id: user.id }
    let!(:new_room)  { FactoryGirl.create :room, name: 'New Room', resource_owner_id: user.id }
    let!(:not_owned) { FactoryGirl.create(:floor) }

    let(:uri) { "/locations/#{resource.id}" }

    let(:params) {{
      name:      'updated', 
      into:      LocationDecorator.decorate(new_house).uri, 
      locations: [LocationDecorator.decorate(new_room).uri] 
    }}

    context 'when updates the connections' do

      before { page.driver.put uri, params.to_json }
      before { resource.reload }

      it 'updates the resource connections' do
        resource.parent.should     == new_house.reload
        resource.children.first.should == new_room.reload
      end
    end

    it_behaves_like 'an updatable resource'
    it_behaves_like 'a not owned resource', 'page.driver.put(uri)'
    it_behaves_like 'a not found resource', 'page.driver.put(uri)'
    it_behaves_like 'a validated resource', 'page.driver.put(uri, { name: "" }.to_json)', { method: 'PUT', error: 'can\'t be blank' }
  end

  context 'DELETE /locations/:id' do
    let!(:resource)  { FactoryGirl.create :location, resource_owner_id: user.id }
    let(:uri)        { "/locations/#{resource.id}" }

    it_behaves_like 'a deletable resource'
    it_behaves_like 'a not owned resource', 'page.driver.delete(uri)'
    it_behaves_like 'a not found resource', 'page.driver.delete(uri)'
  end
end
