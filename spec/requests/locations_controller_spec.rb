require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "LocationsController" do
  before { Location.destroy_all }
  before { host! "http://" + host }


  # -----------------
  # GET /locations
  # -----------------
  context ".index" do

    let(:uri) do
      "/locations"
    end

    let!(:root) do
      FactoryGirl.create :root
    end

    let!(:resource_not_owned) do
      FactoryGirl.create :location_not_owned
    end

    it_should_behave_like "not authorized resource", "visit(uri)"

    context "when logged in" do

      before do
        basic_auth
      end

      it "shows all owned resources" do
        visit uri
        page.status_code.should == 200
        should_have_owned_location root
      end


      ## ---------
      ## Search
      ## ---------
      #shared_examples "searching location" do
        #context "#name" do
          #before { @name = "My name is location" }
          #before { @result = FactoryGirl.create(:location_no_connections, name: @name) }

          #it "finds the desired location" do
            #visit "#{@uri}?name=name+is"
            #should_contain_location @result
            #page.should_not have_content @resource.name
          #end
        #end
      #end


      ## ------------
      ## Pagination
      ## ------------
      #shared_examples "paginating location" do
        #before { Location.destroy_all }
        #before { @resource = LocationDecorator.decorate(FactoryGirl.create(:location_no_connections)) }
        #before { @resources = FactoryGirl.create_list(:location, Settings.pagination.per + 5, name: 'Extra location') }

        #context "with :start" do
          #it "shows the next page" do
            #visit "#{@uri}?start=#{@resource.uri}"
            #page.status_code.should == 200
            #should_contain_location @resources.first
            #page.should_not have_content @resource.name
          #end
        #end

        #context "with :per" do
          #context "when not set" do
            #it "shows the default number of resources" do
              #visit "#{@uri}"
              #JSON.parse(page.source).should have(Settings.pagination.per).items
            #end
          #end

          #context "when set to 5" do
            #it "shows 5 resources" do
              #visit "#{@uri}?per=5"
              #JSON.parse(page.source).should have(5).items
            #end
          #end

          #context "when set too high value" do
            #before { Settings.pagination.max_per = 30 }

            #it "shows the max number of resources allowed" do
              #visit "#{@uri}?per=100000"
              #JSON.parse(page.source).should have(30).items
            #end
          #end

          #context "when set to not valid value" do
            #it "shows the default number of resources" do
              #visit "#{@uri}?per=not_valid"
              #JSON.parse(page.source).should have(Settings.pagination.per).items
            #end
          #end
        #end
      #end
    end
  end



  ## -----------------------
  ## GET /locations/public
  ## -----------------------
  #context ".index" do
    #before { @uri = "/locations/public" }
    #before { @resource = FactoryGirl.create(:location) }
    #before { @resource_not_owned = FactoryGirl.create(:location_not_owned) }

    #context "when not logged in" do
      #it "shows all owned and not owned resources" do
        #visit @uri
        #page.status_code.should == 200
        #JSON.parse(page.source).should have(2).items
      #end
    #end

    #context "when logged in" do
      #before { basic_auth }

      #it "shows all owned and not owned resources" do
        #visit @uri
        #page.status_code.should == 200
        #JSON.parse(page.source).should have(2).items
      #end

      #it_should_behave_like "searching location"
      #it_should_behave_like "paginating location"
    #end
  #end



  ## ---------------------
  ## GET /locations/:id
  ## ---------------------
  #context ".show" do
    #before { @resource = LocationDecorator.decorate(FactoryGirl.create(:location, properties: @properties, functions: @functions, statuses: @statuses, categories: @categories)) }
    #before { @uri = "/locations/#{@resource.id.as_json}" }
    #before { @resource_not_owned = FactoryGirl.create(:location_not_owned) }

    #context "when not logged in" do
      #it "view the owned resource" do
        #visit @uri
        #page.status_code.should == 200
        #should_have_location @resource
      #end
    #end

    #context "when logged in" do
      #before { basic_auth }

      #it "view the owned resource" do
        #visit @uri
        #page.status_code.should == 200
        #should_have_location @resource
      #end

      #context "when checking connections" do
        #before { visit @uri }

        #it "has properties" do
          #page.should have_content('"name":"Status"')
        #end

        #it "has functions" do
          #page.should have_content('"name":"Set intensity"')
        #end

        #it "has properties" do
          #page.should have_content('"name":"Setting intensity"')
        #end

        #it "has properties" do
          #page.should have_content('"name":"Lighting"')
        #end
      #end

      #it "exposes the location URI" do
        #visit @uri
        #uri = "http://www.example.com/locations/#{@resource.id.as_json}"
        #@resource.uri.should == uri
      #end

      #context "with host" do
        #it "changes the URI" do
          #visit "#{@uri}?host=www.lelylan.com"
          #@resource.uri.should match("http://www.lelylan.com/")
        #end
      #end

      #context "with public resources" do
        #before { @uri = "/locations/#{@resource_not_owned._id}" }

        #it "views the not owned resource" do
          #visit @uri
          #page.status_code.should == 200
          #should_have_location @resource_not_owned
        #end
      #end
    #end
  #end



  ## ---------------
  ## POST /locations
  ## ---------------
  #context ".create" do
    #before { @uri =  "/locations" }

    #it_should_behave_like "not authorized resource", "page.driver.post(@uri)"

    #context "when logged in" do
      #before { basic_auth }
      #before { @params = { name: 'Location created', properties: @properties, functions: @functions, statuses: @statuses } }

      #it "creates the resource" do
        #page.driver.post @uri, @params.to_json
        #@resource = Location.last
        #page.status_code.should == 201
        #should_have_location @resource
      #end

      #it "creates the resource connections" do
        #page.driver.post @uri, @params.to_json
        #@resource = Location.last
        #@resource.property_ids.should have(2).items
        #@resource.function_ids.should have(3).items
        #@resource.status_ids.should have(1).items
      #end

      #it "stores the resource" do
        #expect{ page.driver.post(@uri, @params.to_json) }.to change{ Location.count }.by(1)
      #end

      #it_validates "not valid params", "page.driver.post(@uri, @params.to_json)", { method: "POST", error: "Name can't be blank" }
      #it_validates "not valid JSON", "page.driver.post(@uri, @params.to_json)", { method: "POST" }
    #end
  #end



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
