class DescendantsController < ApplicationController
  include Lelylan::Search::URI

  doorkeeper_for :index, scopes: [:read, :write]

  before_filter :find_owned_resources
  before_filter :find_resource

  def index
  end

  private

  def find_owned_resources
    @locations = Location.where(resource_owner_id: current_user.id.to_s)
  end

  def find_resource
    @location = @locations.find(params[:location_id])
    @descendants_locations = @location.descendants
    @descendants_devices   = @location.descendants_devices
  end

end
