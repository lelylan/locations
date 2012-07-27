class UserDecorator < ApplicationDecorator
  decorates :User

  def user_host
    host = h.params[:host] || 'http://people.lelylan.com'
  end

  def uri
    "#{user_host}/users/#{model.id}"
  end
end
