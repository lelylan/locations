require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'Scope' do

  before { Location.delete_all }

  let!(:application) { FactoryGirl.create :application }
  let!(:user)        { FactoryGirl.create :user }
  let!(:resource)    { FactoryGirl.create :root, resource_owner_id: user.id }

  describe ':read' do

    let!(:scopes)       { 'read' }
    let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: scopes, resource_owner_id: user.id }

    before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

    it 'authorizes GET /locations' do
      page.driver.get '/locations'
      page.status_code.should == 200
    end

    it 'authorizes GET /locations/:id' do
      page.driver.get "/locations/#{resource.id}"
      page.status_code.should == 200
    end

    it 'does not authorize POST /locations' do
      page.driver.post '/locations'
      has_unauthorized_resource
    end

    it 'does not authorize PUT /locations/:id' do
      page.driver.put "/locations/#{resource.id}"
      has_unauthorized_resource
    end

    it 'does not authorize DELETE /locations/:id' do
      page.driver.delete "/locations/#{resource.id}"
      has_unauthorized_resource
    end

    it 'authorizes GET /locations/:id/descendants' do
      page.driver.get "/locations/#{resource.id}/descendants"
      page.status_code.should == 200
    end
  end

  describe ':write' do

    let!(:scopes)       { 'write' }
    let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: scopes, resource_owner_id: user.id }

    before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

    it 'authorizes GET /locations' do
      page.driver.get '/locations'
      page.status_code.should == 200
    end

    it 'authorizes GET /locations/:id' do
      page.driver.get "/locations/#{resource.id}"
      page.status_code.should == 200
    end

    it 'authorizes POST /locations' do
      page.driver.post '/locations'
      page.status_code.should == 422
    end

    it 'authorizes PUT /locations/:id' do
      page.driver.put "/locations/#{resource.id}"
      page.status_code.should == 422
    end

    it 'authorizes DELETE /locations/:id' do
      page.driver.delete "/locations/#{resource.id}"
      page.status_code.should == 200
    end
    
    it 'authorizes GET /locations/:id/descendants' do
      page.driver.get "/locations/#{resource.id}/descendants"
      page.status_code.should == 200
    end
  end
end
