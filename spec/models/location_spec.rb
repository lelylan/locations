require 'spec_helper'

describe Location do

  it { should validate_presence_of('name') }

  it { Settings.validation.uris.valid.each {|uri| should allow_value(uri).for(:parent_uri)} }

  it { Settings.validation.uris.not_valid.each {|uri| should_not allow_value(uri).for(:parent_uri)} }

  context "#parse_parent_uri" do

    context "when parent_uri is valid" do

      let(:root) do
        FactoryGirl.create :root
      end

      let(:root_uri) do
        "http://location.lelylan.com/locations/#{root.id}"
      end

      context "when adds a child" do

        let!(:children) do
          root.children.create(name: 'Child', parent_uri: root_uri)
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
    end
  end

  context "with parent" do

    let(:floor) do
      FactoryGirl.create :floor, :with_parent
    end

    it "has parent" do
      floor.parent.name.should == 'House'
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

  context "when parent is deleted" do

    let!(:floor) do
      FactoryGirl.create :floor, :with_parent
    end

    before do
      floor.parent.destroy
    end

    it "deletes children" do
      Location.all.should have(0).items
    end
  end
end
