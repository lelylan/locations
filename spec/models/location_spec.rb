require 'spec_helper'

describe Location do

  it { should validate_presence_of('name') }

  it { Settings.validation.uris.valid.each {|uri| should allow_value(uri).for(:parent)} }

  it { Settings.validation.uris.not_valid.each {|uri| should_not allow_value(uri).for(:parent)} }

  context "when adds parent" do
    context "when not owned" do

      let!(:not_owned) do
        FactoryGirl.create :location_not_owned
      end

      let(:parent) do
        "http://www.example.com/locations/#{not_owned.id}"
      end

      it "adds locations" do
        expect{ FactoryGirl.create :floor, parent: parent }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when is an array and not a string" do

      let!(:house) do
        FactoryGirl.create :location
      end

      let(:parent) do
        [ "http://www.example.com/locations/#{house.id}" ]
      end

      it "adds locations" do
        expect{ FactoryGirl.create :floor, parent: parent }.to raise_error(Lelylan::Errors::ValidURI)
      end
    end
  end

  context "when adds locations" do

    let!(:room) do
      FactoryGirl.create :room
    end

    context "when valid URIs" do

      let(:locations) do
        [ "http://www.example.com/locations/#{room.id}" ]
      end

      let(:floor) do
        FactoryGirl.create :floor, locations: locations
      end

      it "adds locations" do
        floor.children.should have(1).item
      end
    end

    context "when not valid URIs" do

      let(:locations) do
        [ "not_valid" ]
      end

      it "adds locations" do
        expect{ FactoryGirl.create :floor, locations: locations }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when empty URIs" do

      let(:locations) do
        []
      end

      let(:floor) do
        FactoryGirl.create :floor, locations: locations
      end

      it "adds locations" do
        floor.children.should have(0).item
      end
    end

    context "when a location is not owned" do

      let!(:not_owned) do
        FactoryGirl.create :location_not_owned
      end

      let(:locations) do
        [ "http://www.example.com/locations/#{not_owned.id}" ]
      end

      it "adds locations" do
        expect{ FactoryGirl.create :floor, locations: locations }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  context "when adds a child" do

    let(:root) do
      FactoryGirl.create :root
    end

    let!(:children) do
      root.children.create(name: 'Child')
    end

    it "creates a child" do
      root.children.should have(1).item
    end

    it "creates a child" do
      children.parent_id.should == root.id
    end

    context "when moves the child to a new parent" do

      let(:parent) do
        FactoryGirl.create :location, name: 'New parent'
      end

      before do
        children.move_to_child_of(parent)
      end

      it "has the new parent" do
        parent.children.should have(1).item
      end

      it "loses the old parent" do
        root.reload.children.should have(0).items
      end
    end
  end

  context "when checking relations" do

    context "with parent" do

      let(:floor) do
        FactoryGirl.create :floor, :with_parent
      end

      it "has parent" do
        floor.the_parent.name.should == 'House'
      end
    end

    context "with ancestors" do

      let(:floor) do
        FactoryGirl.create :floor, :with_ancestors
      end

      it "has parent" do
        floor.ancestors.should have(2).items
      end
    end

    context "with children" do

      let(:floor) do
        FactoryGirl.create :floor, :with_children
      end

      it "has parent" do
        floor.children.should have(1).items
      end
    end

    context "with descendants" do

      let(:floor) do
        FactoryGirl.create :floor, :with_descendants
      end

      it "has parent" do
        floor.descendants.should have(2).items
      end
    end
  end

  context "when parent is deleted" do

    let!(:floor) do
      FactoryGirl.create :floor, :with_parent
    end

    before do
      floor.the_parent.destroy
    end

    it "deletes children" do
      Location.all.should have(0).items
    end
  end
end
