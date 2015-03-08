require 'nexmo'

nexmo = Nexmo::Client.new(key: 'YOUR API KEY', secret: 'YOUR API SECRET')

nexmo.send_message(from: 'Ruby', to: 'YOUR NUMBER', text: 'Hello world')