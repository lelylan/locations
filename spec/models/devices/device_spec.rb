require 'spec_helper'

describe Device do

  let(:user)   { FactoryGirl.create :user }
  let(:device) { FactoryGirl.create :device, resource_owner_id: user.id }

  it 'connects to people database' do
    Device.database_name.should == 'devices_test'
  end

  it 'creates a device' do
    device.id.should_not be_nil
  end

  it 'belongs to the user' do
    device.resource_owner_id.should == user.id
  end
end
