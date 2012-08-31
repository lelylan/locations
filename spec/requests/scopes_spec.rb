require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'Scope' do

  let!(:application) { FactoryGirl.create :application }
  let!(:user)        { FactoryGirl.create :user }

  %w(locations-read resources-read).each do |scope|

    context "with token #{scope}" do

      let!(:access_token) { FactoryGirl.create :access_token, scopes: scope, resource_owner_id: user.id }

      before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

      let(:location) { FactoryGirl.create :root, resource_owner_id: user.id }

      it { should authorize 'get /locations' }
      it { should authorize "get /locations/#{location.id}" }
      it { should authorize "get /locations/#{location.id}/descendants" }

      it { should_not authorize 'post   /locations' }
      it { should_not authorize "put    /locations/#{location.id}" }
      it { should_not authorize "delete /locations/#{location.id}" }
    end
  end

  %w(locations resources).each do |scope|

    context "with token #{scope}" do

      let!(:access_token) { FactoryGirl.create :access_token, scopes: scope, resource_owner_id: user.id }

      before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

      let(:location) { FactoryGirl.create :root, resource_owner_id: user.id }

      it { should authorize 'get    /locations' }
      it { should authorize "get    /locations/#{location.id}" }
      it { should authorize "get    /locations/#{location.id}/descendants" }
      it { should authorize 'post   /locations' }
      it { should authorize "put    /locations/#{location.id}" }
      it { should authorize "delete /locations/#{location.id}" }
    end
  end
end
