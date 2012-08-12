require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'Scope' do

  let!(:application) { FactoryGirl.create :application }
  let!(:user)        { FactoryGirl.create :user }

  context 'with read scope' do

    let!(:scopes)       { 'read' }
    let!(:access_token) { FactoryGirl.create :access_token, scopes: scopes, resource_owner_id: user.id }

    before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

    context 'locations controller' do

      let(:resource) { FactoryGirl.create :root, resource_owner_id: user.id }

      it { should authorize 'get /locations' }
      it { should authorize "get /locations/#{resource.id}" }
      it { should authorize "get /locations/#{resource.id}/descendants" }

      it { should_not authorize 'post /locations' }
      it { should_not authorize "put /locations/#{resource.id}" }
      it { should_not authorize "delete /locations/#{resource.id}" }
    end
  end

  context 'with write scope' do

    let!(:scopes)       { 'write' }
    let!(:access_token) { FactoryGirl.create :access_token, scopes: scopes, resource_owner_id: user.id }

    before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

    context 'locations controller' do

      let(:resource) { FactoryGirl.create :root, resource_owner_id: user.id }

      it { should authorize 'get /locations' }
      it { should authorize "get /locations/#{resource.id}" }
      it { should authorize "get /locations/#{resource.id}/descendants" }
      it { should authorize 'post /locations' }
      it { should authorize "put /locations/#{resource.id}" }
      it { should authorize "delete /locations/#{resource.id}" }
    end
  end
end
