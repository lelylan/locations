require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "LocationsController" do
  before { Location.destroy_all }
  before { host! "http://" + host }

  ## -----------------
  ## GET /locations
  ## ----------------

  #context ".index" do

    #let(:uri) do
      #"/locations"
    #end

    #let!(:resource) do
      #FactoryGirl.create :root
    #end

    #let!(:resource_not_owned) do
      #FactoryGirl.create :location_not_owned
    #end

    #it_should_behave_like "not authorized resource", "visit(uri)"

    #context "when logged in" do

      #before do
        #basic_auth
      #end

      #it "shows all owned resources" do
        #visit uri
        #page.status_code.should == 200
        #should_have_owned_location resource
      #end


      ## ---------
      ## Search
      ## ---------
      #context "when searching" do

        #context "#name" do

          #let(:name) do
            #"My name is location"
          #end

          #let!(:result) do 
            #FactoryGirl.create(:location, name: name)
          #end

          #it "returns the searched location" do
            #visit "#{uri}?name=name+is"
            #should_contain_location result
            #page.should_not have_content resource.name
          #end
        #end
      #end


      ## ------------
      ## Pagination
      ## ------------
      #context "paginating location" do

        #let!(:resource) do
          #LocationDecorator.decorate(FactoryGirl.create(:location))
        #end

        #let!(:resources) do 
          #FactoryGirl.create_list(:location, Settings.pagination.per + 5, name: 'Extra location')
        #end

        #context "with :start" do

          #it "shows the next page" do
            #visit "#{uri}?start=#{resource.uri}"
            #page.status_code.should == 200
            #should_contain_location resources.first
            #page.should_not have_content resource.name
          #end
        #end

        #context "with :per" do

          #context "when not set" do

            #it "shows the default number of resources" do
              #visit uri
              #JSON.parse(page.source).should have(Settings.pagination.per).items
            #end
          #end

          #context "when set to 5" do

            #it "shows 5 resources" do
              #visit "#{uri}?per=5"
              #JSON.parse(page.source).should have(5).items
            #end
          #end

          #context "when set too high value" do

            #before { Settings.pagination.max_per = 30 }

            #it "shows the max number of allowed resources" do
              #visit "#{uri}?per=100000"
              #JSON.parse(page.source).should have(30).items
            #end
          #end

          #context "when set to a not valid value" do

            #it "shows the default number of resources" do
              #visit "#{uri}?per=not_valid"
              #JSON.parse(page.source).should have(Settings.pagination.per).items
            #end
          #end
        #end
      #end
    #end
  #end

  ## ---------------------
  ## GET /locations/:id
  ## ---------------------

  #context ".show" do

    #let!(:resource) do
      #LocationDecorator.decorate FactoryGirl.create(:floor, :with_ancestors, :with_descendants, :with_devices)
    #end

    #let!(:resource_not_owned) do
      #FactoryGirl.create(:location_not_owned)
    #end

    #let(:uri) do
      #"/locations/#{resource.id}"
    #end

    #it_should_behave_like "not authorized resource", "visit(uri)"

    #context "when logged in" do

      #before do
        #basic_auth
      #end

      #it "view the owned resource" do
        #visit uri
        #page.status_code.should == 200
        #should_have_location resource
      #end

      #context "when checking connection" do

        #before do
          #visit uri
        #end

        #context "parent" do

          #let(:parent) do
            #LocationDecorator.decorate resource.the_parent
          #end

          #it "has parent" do
            #page.should have_content(parent.uri)
          #end
        #end

        #context "ancestors" do

          #let(:ancestor) do
            #LocationDecorator.decorate resource.ancestors.first
          #end

          #it "has ancestors" do
            #page.should have_content(ancestor.uri)
          #end
        #end

        #context "children" do

          #let(:children) do
            #LocationDecorator.decorate resource.children.first
          #end

          #it "has child" do
            #page.should have_content(children.uri)
          #end
        #end

        #context "descendants" do

          #let(:descendants) do
            #LocationDecorator.decorate resource.descendants.last
          #end

          #it "has descendants" do
            #page.should have_content(descendants.uri)
          #end
        #end

        #context "children devices" do

          #it "has children devices" do
            #page.should have_content(resource.devices[0][:uri])
          #end
        #end

        #context "descendants devices" do

          #it "has descendants devices" do
            #page.should have_content(resource.descendants.last.devices[0][:uri])
          #end
        #end
      #end

      #it "exposes the location URI" do
        #visit uri
        #uri = "http://www.example.com/locations/#{resource.id}"
        #resource.uri.should == uri
      #end

      #context "with host" do

        #it "changes the URI" do
          #visit "#{uri}?host=www.lelylan.com"
          #resource.uri.should match("http://www.lelylan.com/")
        #end
      #end
    #end
  #end



  # ---------------
  # POST /locations
  # ---------------
  context ".create" do

    let(:uri) do
      "/locations"
    end

    it_should_behave_like "not authorized resource", "page.driver.post(uri)"

    context "when logged in" do

      before do
        basic_auth
      end

      let!(:floor) do
        LocationDecorator.decorate FactoryGirl.create(:floor, :with_ancestors, :with_descendants)
      end

      let(:params) do
        { 
          name: 'Magic floor', 
          parent: LocationDecorator.decorate(floor.the_parent).uri, 
          locations: [
            LocationDecorator.decorate(floor.children.first).uri,
          ],
          devices: [
            Settings.device.uri,
            Settings.device.another.uri
          ]
        }
      end

      it "creates the resource" do
        page.driver.post uri, params.to_json
        resource = Location.last
        page.status_code.should == 201
        should_have_location resource
      end

      it "creates the resource connections" do
        page.driver.post uri, params.to_json
        resource = Location.last
        resource.the_parent.should_not == nil
        resource.ancestors.should have(2).itmes
        resource.children.should have(1).item
        resource.descendants.should have(2).items
      end

      it "stores the resource" do
        expect{ page.driver.post(uri, params.to_json) }.to change{ Location.count }.by(1)
      end

      it_validates "not valid params", "page.driver.post(uri, params.to_json)", { method: "POST", error: "Name can't be blank" }
      it_validates "not valid JSON", "page.driver.post(uri, params.to_json)", { method: "POST" }
    end
  end



  ## ---------------------
  ## PUT /locations/:id
  ## ---------------------
  #context ".update" do
    #before { @resource = FactoryGirl.create(:location, properties: @properties, functions: @functions) }
    #before { @uri = "/locations/#{@resource.id.as_json}" }
    #before { @resource_not_owned = FactoryGirl.create(:location_not_owned) }

    #it_should_behave_like "not authorized resource", "page.driver.put(@uri)"

    #context "when logged in" do
      #before { basic_auth }
      #before { @params = { name: 'Updated', statuses: @statuses } }

      #it "updates the resource" do
        #page.driver.put @uri, @params.to_json
        #@resource.reload
        #page.status_code.should == 200
        #page.should have_content "Updated"
      #end

      #it "updates the resource properties" do
        #page.driver.put @uri, @params.to_json
        #page.should_not have_content '"statuses":[]'
      #end

      #it_should_behave_like "a rescued 404 resource", "page.driver.put(@uri)", "locations"
      #it_validates "not valid JSON", "page.driver.put(@uri, @params.to_json)", { method: "PUT" }
    #end
  #end



  ## ------------------------
  ## DELETE /locations/:id
  ## ------------------------
  #context ".destroy" do
    #before { @resource = FactoryGirl.create(:location_no_connections) }
    #before { @uri =  "/locations/#{@resource.id.as_json}" }
    #before { @resource_not_owned = FactoryGirl.create(:location_not_owned) }

    #it_should_behave_like "not authorized resource", "page.driver.delete(@uri)"

    #context "when logged in" do
      #before { basic_auth } 

      #scenario "delete resource" do
        #expect{ page.driver.delete(@uri) }.to change{ Location.count }.by(-1)
        #page.status_code.should == 200
        #should_have_location @resource
      #end

      #it_should_behave_like "a rescued 404 resource", "page.driver.delete(@uri)", "locations"
    #end
  #end
end
