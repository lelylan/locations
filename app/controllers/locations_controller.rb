class LocationsController < ApplicationController
  doorkeeper_for :index, :show, scopes: [:read, :write]
  doorkeeper_for :create, :update, :destroy, scopes: [:write]

  before_filter :find_owned_resources
  before_filter :find_resource, only: %w(show update destroy)
  before_filter :search_params, only: %w(index)
  before_filter :pagination,    only: %w(index)

  def index
    @locations = @locations.limit(params[:per])
  end

  def show
  end

  def create
    params.reject!{|k,v| %w(format action controller location).include? k }
    @location = Location.new(params)
    @location.resource_owner_id = current_user.id
    if @location.save!
      render 'show', status: 201, location: LocationDecorator.decorate(@location).uri
    else
      render_422 'notifications.resource.not_valid', @location.errors
    end
  end

  def update
    params.reject!{|k,v| %w(format action controller location).include? k }
    if @location.update_attributes!(params)
      render 'show'
    else
      render_422 'notifications.resource.not_valid', @location.errors
    end
  end

  def destroy
    render 'show'
    @location.safe_destroy
  end

  private

  def find_owned_resources
    @locations = Location.where(resource_owner_id: current_user.id.to_s)
  end

  def find_resource
    @location = @locations.find(params[:id])
  end

  def search_params
    @locations = @locations.where('name like ?', "%#{params[:name]}%") if params[:name]
    @locations = @locations.where(type: params[:type]) if params[:type]
  end

  def pagination
    params[:per] = (params[:per] || Settings.pagination.per).to_i
    params[:per] = Settings.pagination.per if params[:per] == 0 
    params[:per] = Settings.pagination.max_per if params[:per] > Settings.pagination.max_per
    @locations = @locations.where('id > ?', find_id(params[:start])) if params[:start]
  end
end
