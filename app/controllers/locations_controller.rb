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

    def find_owned_resources
      @locations = Location.where(created_from: current_user.uri)
    end

    def find_all_resources
      @locations = Location.all
    end

    def find_resource
      @location = @locations.find(params[:id])
    end

    def pagination
      params[:per] = (params[:per] || Settings.pagination.per).to_i
      params[:per] = Settings.pagination.per if params[:per] == 0 
      params[:per] = Settings.pagination.max_per if params[:per] > Settings.pagination.max_per
      @locations = @locations.gt(_id: find_id_from_uri(params[:start])) if params[:start]
    end

    def search_params
      @locations = @locations.where('name' => /.*#{params[:name]}.*/i) if params[:name]
    end 
end
