object request

node(:status)  { |request| '401' }
node(:method)  { |request| request.method }
node(:request) { |request| request.url }

node(:error) do |request| 
  {
    code: 'notifications.access.denied',
    description: I18n.t('notifications.access.denied')
  }
end
