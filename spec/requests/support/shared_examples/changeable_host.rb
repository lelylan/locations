shared_examples_for 'changeable host' do

  it 'exposes the location URI' do
    page.driver.get uri, token
    uri = "http://www.example.com/locations/#{resource.id}"
    resource.uri.should == uri
  end

  context 'with host' do

    it 'changes the URI' do
      page.driver.get uri, {host: 'http://www.lelylan.com'}.merge(token)
      resource.uri.should match('http://www.lelylan.com')
    end
  end
end
