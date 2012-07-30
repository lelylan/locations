#require 'spec_helper'

#describe Location do

  #before { Location.delete_all }
  #before { Device.delete_all }

  #subject { FactoryGirl.create :location }

  #it { should validate_presence_of('name') }
  #it { should validate_presence_of('type') }

  #it { Settings.validation.uris.valid.each     {|uri| should allow_value(uri).for(:parent)} }
  #it { Settings.validation.uris.not_valid.each {|uri| should_not allow_value(uri).for(:parent)} }

  #it { Settings.locations.types.each {|type| should allow_value(type).for(:type)} }
  #it { [nil, '', 'not_valid'].each   {|type| should_not allow_value(type).for(:type)} }

  #let!(:user) { FactoryGirl.create :user }

  #context 'when connects a parent' do

    #context 'with owned parent' do

      #let!(:parent)  { FactoryGirl.create :location, resource_owner_id: user.id.to_s }
      #let(:resource) { FactoryGirl.create :location, parent: a_uri(parent), resource_owner_id: user.id.to_s }

      #it 'connects the parent' do
        #resource.the_parent.should == parent
      #end
    #end

    #context 'with not owned parent' do

      #let!(:parent)     { FactoryGirl.create :location }
      #let(:resource)    { FactoryGirl.create :location, parent: a_uri(parent), resource_owner_id: user.id.to_s }

      #it 'raises a validation error' do
        #expect { resource }.to raise_error(ActiveRecord::RecordInvalid)
      #end
    #end
  #end

  #context 'when connects locations' do

    #context 'with owned location' do

      #let!(:child)   { FactoryGirl.create :location, resource_owner_id: user.id.to_s }
      #let(:resource) { FactoryGirl.create :location, locations: [ a_uri(child) ], resource_owner_id: user.id.to_s }

      #it 'connects the locations' do
        #resource.children.should have(1).item
      #end
    #end

    #context 'with not owned location' do

      #let!(:child)   { FactoryGirl.create :location }
      #let(:resource) { FactoryGirl.create :location, locations: [ a_uri(child) ], resource_owner_id: user.id.to_s }

      #it 'raises a validation error' do
        #expect { resource }.to raise_error(ActiveRecord::RecordInvalid)
      #end
    #end

    #context 'with one owned location and one not owned location' do

      #let!(:owned_child)     { FactoryGirl.create :location, resource_owner_id: user.id.to_s }
      #let!(:not_owned_child) { FactoryGirl.create :location }
      #let!(:children)        { [ a_uri(owned_child), a_uri(not_owned_child) ] }
      #let(:resource)         { FactoryGirl.create :location, locations: children, resource_owner_id: user.id.to_s }

      #it 'raises a validation error' do
        #expect { resource }.to raise_error(ActiveRecord::RecordInvalid)
      #end
    #end

    #context 'with not valid uri' do

      #let!(:owned_child)     { FactoryGirl.create :location, resource_owner_id: user.id.to_s }
      #let(:resource)         { FactoryGirl.create :location, locations: [ 'not-valid' ], resource_owner_id: user.id.to_s }

      #it 'raises a validation error' do
        #expect { resource }.to raise_error(ActiveRecord::RecordInvalid)
      #end
    #end
  #end

  #context 'when updates connected locations' do

    #context 'with owned locations' do

      #let!(:resource)  { FactoryGirl.create :location, :with_descendants, resource_owner_id: user.id.to_s }
      #let!(:old_child) { resource.children.first }
      #let!(:child)     { FactoryGirl.create :location, resource_owner_id: user.id.to_s }

      #before { resource.update_attributes!(locations: [ a_uri(child) ]) }

      #it 'connects the new location' do
        #resource.children.first.should == child
      #end

      #it 'disconnect previous locations' do
        #resource.children.should_not include old_child
      #end

      #it 'sets previous location as root' do
        #old_child.reload.the_parent.should == nil
      #end
    #end

    #context 'with not owned locations' do

      #let!(:resource)  { FactoryGirl.create :location, :with_descendants, resource_owner_id: user.id.to_s }
      #let!(:old_child) { resource.children.first }
      #let!(:child)     { FactoryGirl.create :location }
      #let(:update)     { resource.update_attributes!(locations: [ a_uri(child) ]) }

      #it 'raises a validation error' do
        #expect { update }.to raise_error(ActiveRecord::RecordInvalid)
      #end

      #it 'does not connect the new location' do
        #expect { update }.to raise_error(ActiveRecord::RecordInvalid)
        #resource.children.first.should == old_child
      #end
    #end

    #context 'with empty locations' do

      #let!(:resource)  { FactoryGirl.create :location, :with_descendants, resource_owner_id: user.id.to_s }
      #let!(:old_child) { resource.children.first }

      #before { resource.update_attributes!(locations: []) }

      #it 'connects the new location' do
        #resource.children.should have(0).items
      #end

      #it 'sets previous location as root' do
        #old_child.reload.the_parent.should == nil
      #end
    #end

    #context 'with no locations' do

      #let!(:resource)  { FactoryGirl.create :location, :with_descendants, resource_owner_id: user.id.to_s }
      #let!(:old_child) { resource.children.first }

      #before { resource.update_attributes!(name: 'Update') }

      #it 'leaves the connected location' do
        #resource.children.first.should == old_child
      #end
    #end
  #end

  #context 'when deletes parent location' do

    #let!(:resource)  { FactoryGirl.create :floor, :with_children }
    #let!(:old_child) { resource.children.first }
    #let!(:records)   { Location.count }
    #before           { resource.delete }

    #it 'deletes the location' do
      #Location.count.should == records - 1
    #end

    #it 'sets children as root' do
      #old_child.parent.should == nil
    #end
  #end

  #context 'when connects a device' do

    #context 'with owned device' do

      #let!(:device)    { FactoryGirl.create :device, resource_owner_id: user.id }
      #let!(:location)  { FactoryGirl.create :floor, :with_descendants, devices: [ a_uri(device) ], resource_owner_id: user.id.to_s }

      #it 'connects the device' do
        #location.devices.first.should == device.id.to_s
      #end

      #it 'stores the device id as a String' do
        #location.devices.first.class.should == String
      #end

      #context 'with children devices' do

        #let(:child_device)   { FactoryGirl.create :device, resource_owner_id: user.id }
        #let(:child_location) { location.children.first }

        #before { child_location.update_attributes!(devices: [ a_uri(child_device) ]) }

        #it 'shows children devices' do
          #location.children_devices.should == [ child_device.id.to_s ]
        #end

        #context 'with descendant devices' do

          #let(:descendant_device)   { FactoryGirl.create :device, resource_owner_id: user.id }
          #let(:descendant_location) { location.descendants.last }

          #before { descendant_location.update_attributes(devices: [ a_uri(descendant_device) ]) }

          #it 'shows children devices' do
            #location.descendants_devices.should == [ child_device.id.to_s, descendant_device.id.to_s ]
          #end
        #end
      #end
    #end

    #context 'with not owned device' do

      #let!(:device)  { FactoryGirl.create :device }
      #let(:resource) { FactoryGirl.create :floor, :with_descendants, devices: [ a_uri(device) ], resource_owner_id: user.id.to_s }

      #it 'raises a validation error' do
        #expect { resource }.to raise_error(ActiveRecord::RecordInvalid)
      #end
    #end

    #context 'when updates connected devices' do

      #let!(:old_device) { FactoryGirl.create :device, resource_owner_id: user.id }
      #let!(:location)   { FactoryGirl.create :floor, :with_descendants, devices: [ a_uri(old_device) ], resource_owner_id: user.id.to_s }
      #let!(:device)     { FactoryGirl.create :device, resource_owner_id: user.id }

      #before { location.update_attributes!(devices: [ a_uri(device) ]) }

      #it 'connects the new device' do
        #location.devices.should == [ device.id.to_s ]
      #end
    #end
  #end
#end
