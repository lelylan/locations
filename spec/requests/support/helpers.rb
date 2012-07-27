module HelperMethods
  # Access token simulation
  def authorized
    token = stub :accessible? => true
    controller.stub(:doorkeeper_token) { token }
  end

  def unauthorized
    token = stub :accessible? => false
    controller.stub(:doorkeeper_token) { token }
  end

  def has_valid_json
    expect { JSON.parse(page.source) }.to_not raise_error
  end
end

RSpec.configuration.include HelperMethods
