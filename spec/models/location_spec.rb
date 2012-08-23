require 'spec_helper'

describe Location do

  subject { FactoryGirl.create :location }

  it { should validate_presence_of('name') }
  it { should validate_presence_of('type') }

  it { Settings.uris.valid.each     {|uri| should allow_value(uri).for(:into)} }
  it { Settings.uris.not_valid.each {|uri| should_not allow_value(uri).for(:into)} }

  it { %w(house floor room).each {|type| should allow_value(type).for(:type)} }
  it { [nil, '', 'not_valid'].each   {|type| should_not allow_value(type).for(:type)} }

  let!(:user) { FactoryGirl.create :user }

  context 'when connects a parent' do

    context 'with owned parent' do

      let!(:parent)  { FactoryGirl.create :location, resource_owner_id: user.id }
      let!(:resource) { FactoryGirl.create :location, into: a_uri(parent), resource_owner_id: user.id }

      it 'connects the child to the parent' do
        resource.reload.parent.should == parent
      end

      it 'connects the parent to the child' do
        parent.children.entries.should == [resource]
      end
    end

    context 'with not owned parent' do

      let!(:parent)     { FactoryGirl.create :location }
      let(:resource)    { FactoryGirl.create :location, into: a_uri(parent), resource_owner_id: user.id }

      it 'raises a validation error' do
        expect { resource }.to raise_error(Mongoid::Errors::Validations)
      end
    end
  end

  context 'when connects locations' do

    context 'with owned location' do

      let!(:child)    { FactoryGirl.create :location, resource_owner_id: user.id }
      let!(:resource) { FactoryGirl.create :location, locations: [ a_uri(child) ], resource_owner_id: user.id }

      it 'connects the child to the parent' do
        child.reload.parent.should == resource
      end

      it 'connects the parent to the child' do
        resource.children.entries.should == [child]
      end
    end

    context 'with not owned location' do

      let!(:child)   { FactoryGirl.create :location }
      let(:resource) { FactoryGirl.create :location, locations: [ a_uri(child) ], resource_owner_id: user.id }

      it 'raises a validation error' do
        expect { resource }.to raise_error(Mongoid::Errors::Validations)
      end
    end

    context 'with one owned location and one not owned location' do

      let!(:owned_child)     { FactoryGirl.create :location, resource_owner_id: user.id }
      let!(:not_owned_child) { FactoryGirl.create :location }
      let!(:children)        { [ a_uri(owned_child), a_uri(not_owned_child) ] }
      let(:resource)         { FactoryGirl.create :location, locations: children, resource_owner_id: user.id }

      it 'raises a validation error' do
        expect { resource }.to raise_error(Mongoid::Errors::Validations)
      end
    end

    context 'with not valid uri' do

      let!(:owned_child)     { FactoryGirl.create :location, resource_owner_id: user.id }
      let(:resource)         { FactoryGirl.create :location, locations: [ 'not-valid' ], resource_owner_id: user.id }

      it 'raises a validation error' do
        expect { resource }.to raise_error(Mongoid::Errors::Validations)
      end
    end
  end

  context 'when updates connected locations' do

    context 'with owned locations' do

      let!(:resource)  { FactoryGirl.create :location, :with_children, resource_owner_id: user.id }
      let!(:old_child) { resource.children.first }
      let!(:child)     { FactoryGirl.create :location, resource_owner_id: user.id }

      before { resource.update_attributes!(locations: [ a_uri(child) ]) }

      it 'connects the new location' do
        resource.children.first.should == child
      end

      it 'disconnect previous locations' do
        resource.children.should_not include old_child
      end

      it 'sets previous location as root' do
        old_child.reload.parent.should == nil
      end
    end

    context 'with not owned locations' do

      let!(:resource)  { FactoryGirl.create :location, :with_children, resource_owner_id: user.id }
      let!(:old_child) { resource.children.first }
      let!(:child)     { FactoryGirl.create :location }
      let(:update)     { resource.update_attributes!(locations: [ a_uri(child) ]) }

      it 'raises a validation error' do
        expect { update }.to raise_error(Mongoid::Errors::Validations)
      end

      it 'does not connect the new location' do
        expect { update }.to raise_error(Mongoid::Errors::Validations)
        resource.children.first.should == old_child
      end
    end

    context 'with empty locations' do

      let!(:resource)  { FactoryGirl.create :location, :with_children, resource_owner_id: user.id }
      let!(:old_child) { resource.children.first }

      before { resource.update_attributes!(locations: []) }

      it 'connects the new location' do
        resource.children.should have(0).items
      end

      it 'sets previous location as root' do
        old_child.reload.parent.should == nil
      end
    end

    context 'with no locations' do

      let!(:resource)  { FactoryGirl.create :location, :with_children, resource_owner_id: user.id }
      let!(:old_child) { resource.children.first }

      before { resource.update_attributes!(name: 'Update') }

      it 'leaves the connected location' do
        resource.children.first.should == old_child
      end
    end
  end

  context 'when deletes parent location' do

    let!(:resource)   { FactoryGirl.create :floor, :with_parent, :with_children }
    let!(:old_child)  { resource.children.first }
    let!(:old_parent) { resource.parent }

    let(:destroy) { resource.destroy }

    it 'deletes the location' do
      expect { destroy }.to change{ Location.count }.by(-1)
    end

    it 'removes parent connection' do
      expect { destroy }.to change{ old_parent.children.count }.by(-1)
    end

    it 'sets children as root' do
      destroy; old_child.reload.parent.should == nil
    end
  end

  context 'when connects a device' do

    context 'with owned device' do

      let!(:device)    { FactoryGirl.create :device, resource_owner_id: user.id }
      let!(:location)  { FactoryGirl.create :floor, :with_children, devices: [ a_uri(device) ], resource_owner_id: user.id }

      it 'connects the device' do
        location.device_ids.first.should == device.id
      end

      it 'stores the device id as BSON ObjectId' do
        location.device_ids.first.class.should == Moped::BSON::ObjectId
      end

      context 'with children devices' do

        let!(:child)        { location.children.first }
        let!(:child_device) { FactoryGirl.create :device, resource_owner_id: user.id }

        before { child.update_attributes!(devices: [ a_uri(child_device) ]) }

        it 'shows children devices' do
          location.children_devices.should == [ child_device.id ]
        end

        context 'with descendant devices' do

          let(:descendant)        { FactoryGirl.create :room, name: 'Barbie room', parent_id: child.id, resource_owner_id: user.id }
          let(:descendant_device) { FactoryGirl.create :device, resource_owner_id: user.id }

          before { descendant.update_attributes(devices: [ a_uri(descendant_device) ]) }

          it 'shows children devices' do
            location.descendants_devices.should == [ child_device.id, descendant_device.id ]
          end
        end
      end
    end

    context 'with not owned device' do

      let!(:device)  { FactoryGirl.create :device }
      let(:resource) { FactoryGirl.create :floor, :with_children, devices: [ a_uri(device) ], resource_owner_id: user.id }

      it 'raises a validation error' do
        expect { resource }.to raise_error(Mongoid::Errors::Validations)
      end
    end

    context 'when updates connected devices' do

      let!(:old_device) { FactoryGirl.create :device, resource_owner_id: user.id }
      let!(:location)   { FactoryGirl.create :floor, :with_children, devices: [ a_uri(old_device) ], resource_owner_id: user.id }
      let!(:device)     { FactoryGirl.create :device, resource_owner_id: user.id }

      before { location.update_attributes!(devices: [ a_uri(device) ]) }

      it 'connects the new device' do
        location.device_ids.should == [ device.id ]
      end
    end
  end

  #context 'when create a zone' do
    #it 'does not change the tree structure' do
    #end
  #end
end
