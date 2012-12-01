class LocationsController < ApplicationController
  eventable_for :location, resource: 'locations', only: %w(create update destroy)

  doorkeeper_for :index, :show, scopes: Settings.scopes.read.map(&:to_sym)
  doorkeeper_for :create, :update, :destroy, scopes: Settings.scopes.write.map(&:to_sym)

  before_filter :find_owned_resources
  before_filter :find_resource, only: %w(show update destroy)
  before_filter :search_params, only: %w(index)
  before_filter :pagination,    only: %w(index)

  def index
    @locations = @locations.limit(params[:per])
    render json: @locations
  end

  def show
    render json: @location if stale?(@location)
  end

  def create
    @location = Location.new(params)
    @location.resource_owner_id = current_user.id
    if @location.save
      render json: @location, status: 201, location: LocationDecorator.decorate(@location).uri
    else
      render_422 'notifications.resource.not_valid', @location.errors
    end
  end

  def update
    if @location.update_attributes(params)
      render json: @location
    else
      render_422 'notifications.resource.not_valid', @location.errors
    end
  end

  def destroy
    render json: @location
    @location.destroy
  end

  private

  def find_owned_resources
    @locations = Location.where(resource_owner_id: current_user.id.to_s)
  end

  def find_resource
    @location = @locations.find(params[:id])
  end

  def search_params
    @locations = @locations.where('name' => /.*#{params[:name]}.*/i) if params[:name]
    @locations = @locations.where(type: params[:type]) if params[:type]
  end

  def pagination
    params[:per] = (params[:per] || Settings.pagination.per).to_i
    params[:per] = Settings.pagination.per if params[:per] == 0
    params[:per] = Settings.pagination.max_per if params[:per] > Settings.pagination.max_per
    @locations = @locations.gt(id: find_id(params[:start])) if params[:start]
  end
end
