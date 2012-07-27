require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'LocationsController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, resource_owner_id: user.id }

  let!(:token)        { { access_token: access_token.token } }

  describe 'GET /locations' do

    let(:uri)                 { '/locations' }
    let!(:resource)           { FactoryGirl.create :root, resource_owner_id: user.id.to_s }
    let!(:resource_not_owned) { FactoryGirl.create :location_not_owned }

    it 'shows all owned resources' do
      page.driver.get uri, token
      page.status_code.should == 200
      has_owned_location resource
    end

    describe 'searching' do

      describe '?name={name}' do

        let!(:params) { { name: 'My name is location' } }
        let!(:result) { FactoryGirl.create(:location, name: params[:name], resource_owner_id: user.id.to_s) }

        it 'returns the searched location' do
          page.driver.get uri, params.merge(token)
          contains_location result
          page.should_not have_content resource.name
        end
      end

      describe '?type={type}' do

        let!(:result) { FactoryGirl.create :room, type: 'room', resource_owner_id: user.id.to_s }
        let!(:params) { { type: 'room' } }

        it 'returns the searched location' do
          page.driver.get uri, params.merge(token)
          contains_location result
          page.should_not have_content resource.name
        end
      end
    end

    describe 'pagination' do

      let!(:resource)  { LocationDecorator.decorate(FactoryGirl.create(:location, resource_owner_id: user.id.to_s)) }
      let!(:resources) { FactoryGirl.create_list(:location, Settings.pagination.per + 5, name: 'Extra location', resource_owner_id: user.id.to_s) }

      describe '?start={uri}' do

        it 'shows the next page' do
          page.driver.get uri, { start: resource.uri }.merge(token)
          page.status_code.should == 200
          contains_location resources.first
          page.should_not have_content resource.name
        end
      end

      describe '?per={nil}' do

        it 'shows the default number of resources' do
          page.driver.get uri, token
          JSON.parse(page.source).should have(Settings.pagination.per).items
        end
      end

      describe '?per=5' do

        it 'shows 5 resources' do
          page.driver.get uri, { per: 5 }.merge(token)
          JSON.parse(page.source).should have(5).items
        end
      end

      context '?per=100000' do

        before { Settings.pagination.max_per = 30 }

        it 'shows the max number of allowed resources' do
          page.driver.get uri, { per: 100000 }.merge(token)
          JSON.parse(page.source).should have(30).items
        end
      end

      context '?per=not-valid' do

        it 'shows the default number of resources' do
          page.driver.get uri, { per: 'not-valid' }.merge(token)
          JSON.parse(page.source).should have(Settings.pagination.per).items
        end
      end
    end

## ---------------------
## GET /locations/:id
## ---------------------

#context '.show' do

#let!(:resource) do
#LocationDecorator.decorate FactoryGirl.create(:floor, :with_ancestors, :with_descendants, :with_devices)
#end

#let!(:resource_not_owned) do
#FactoryGirl.create(:location_not_owned)
#end

#let(:uri) do
#'/locations/#{resource.id}'
#end

#it_should_behave_like 'not authorized resource', 'visit(uri)'

#context 'when logged in' do

#before do
#basic_auth
#end

#it 'view the owned resource' do
#visit uri
#page.status_code.should == 200
#should_have_location resource
#end

#context 'when checking connection' do

#before do
#visit uri
#end

#context 'parent' do

#let(:parent) do
#LocationDecorator.decorate resource.the_parent
#end

#it 'has parent' do
#page.should have_content(parent.uri)
#end
#end

#context 'ancestors' do

#let(:ancestor) do
#LocationDecorator.decorate resource.ancestors.first
#end

#it 'has ancestors' do
#page.should have_content(ancestor.uri)
#end
#end

#context 'children' do

#let(:children) do
#LocationDecorator.decorate resource.children.first
#end

#it 'has child' do
#page.should have_content(children.uri)
#end
#end

#context 'descendants' do

#let(:descendants) do
#LocationDecorator.decorate resource.descendants.last
#end

#it 'has descendants' do
#page.should have_content(descendants.uri)
#end
#end

#context 'children devices' do

#it 'has children devices' do
#page.should have_content(resource.devices[0][:uri])
#end
#end

#context 'descendants devices' do

#it 'has descendants devices' do
#page.should have_content(resource.descendants.last.devices[0][:uri])
#end
#end
#end

#it 'exposes the location URI' do
#visit uri
#uri = 'http://www.example.com/locations/#{resource.id}'
#resource.uri.should == uri
#end

#context 'with host' do

#it 'changes the URI' do
#visit '#{uri}?host=www.lelylan.com'
#resource.uri.should match('http://www.lelylan.com/')
#end
#end
#end
#end



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
  end
end
