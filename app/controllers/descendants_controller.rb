class DescendantsController < ApplicationController
  doorkeeper_for :index, scopes: %w(locations.read locations resources.read resources).map(&:to_sym)

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
  end

end
