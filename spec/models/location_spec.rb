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

      context "when add a child" do

        let!(:children) do
          root.children.create(name: 'Child', parent_uri: root_uri)
        end

        it "creates a child" do
          root.children.should have(1).item
        end

        it "creates a child" do
          children.parent_id.should == root.id
        end
      end
    end
  end
end
