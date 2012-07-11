class LocationsController < ApplicationController
  include Lelylan::Search::URI

  before_filter :find_owned_resources
  before_filter :find_resource, only: %w(show update destroy)
  before_filter :search_params, only: %w(index)
  before_filter :pagination, only: %w(index)


  def index
    @locations = @locations.limit(params[:per])
  end

  def show
  end

  def create
    body = JSON.parse(request.body.read)
    @location = Location.new(body)
    @location.created_from = current_user.uri
    if @location.save

      # Put all of this in a before save so that eveentually it does not create
      # Use attr_accessor to access to self.parent (do not use body)
      if body.parent
        parent = find_location(body.parent.uri)
        @location.move_to_child_of(parent) if parent
      end

      # Put all of this in a before save so that eventually it does not create
      # Use attr_accessor to access to self.locations (do not use body)
      if not body.locations.empty?
        children = find_locations(body.locations)
        children.each { |child| child.move_to_child_of(@location) }
      end

      render 'show', status: 201, location: LocationDecorator.decorate(@location).uri
    else
      render_422 "notifications.resource.not_valid", @location.errors
    end
  end

  def update
    body = JSON.parse(request.body.read)
    if @location.update_attributes(body)
      render 'show'
    else
      render_422 'notifications.resource.not_valid', @location.errors
    end
  end

  def destroy
    render 'show'
    @location.destroy
  end



  private

    # Gets the location from the URI
    def find_location(uri)
      id = find_id(uri)
      Location.where(id: id).where(created_from: current_user.uri).first
    end

    # Gets the locations from the URIs
    def find_locations(uris)
      ids = find_ids(uris)
      Location.where(id: ids).where(created_from: current_user.uri)
    end



    def find_owned_resources
      @locations = Location.where(created_from: current_user.uri)
    end

    def find_resource
      @location = @locations.find(params[:id])
    end

    def search_params
      @locations = @locations.where("name like ?", "%#{params[:name]}%") if params[:name]
    end

    def pagination
      params[:per] = (params[:per] || Settings.pagination.per).to_i
      params[:per] = Settings.pagination.per if params[:per] == 0 
      params[:per] = Settings.pagination.max_per if params[:per] > Settings.pagination.max_per
      @locations = @locations.where("id > ?", find_id(params[:start])) if params[:start]
    end
end
