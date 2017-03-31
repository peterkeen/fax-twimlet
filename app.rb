require 'sinatra'
require 'pony'
require 'twilio-ruby'

set :port, ENV['PORT'] || 4567

post '/' do
  if params[:FaxStatus] == 'received'
    body = """You have a new fax from #{params[:From]} to #{params[:To]}.

Click this link to view the fax:

#{params[:MediaUrl]}
"""

    Pony.mail(
      to: params[:email],
      subject: "Fax received from #{params[:From]}",
      body: body,
      via: :smtp,
      via_options: {
        address:        ENV['SMTP_SERVER_ADDRESS'],
        port:           ENV['SMTP_SERVER_PORT'],
        user_name:      ENV['SMTP_SERVER_USERNAME'],
        password:       ENV['SMTP_SERVER_PASSWORD'],
        authentication: 'plain',
        domain:         'feeds.bugsplat.info',
        enable_starttls_auto: true
      }
    )
  end

  Twilio::TwiML::Response.new do |r|
    r.Receive action: request.url
  end.text
end
