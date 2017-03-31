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
    subject = "Fax received from #{params[:From]}"
    send_mail(params[:email], subject, body)
  elsif params[:FaxStatus] == 'delivered'
    body = """Your fax has been delivered to #{params[:To]}.

Click this link to view the fax:

#{params[:MediaUrl]}
"""
    subject = "Fax delivered to #{params[:to]}"
    send_mail(params[:email], subject, body)
  elsif params[:FaxStatus] == 'failed'
    body = """Your fax to #{params[:To]} has failed.

Error #{params[:ErrorCode]}: #{params[:ErrorMessage]}
"""
    subject = "Fax to #{params[:to]} failed"
    send_mail(params[:email], subject, body)
  end

  Twilio::TwiML::Response.new do |r|
    r.Receive action: request.url
  end.text
end

def send_mail(to, subject, body)
    Pony.mail(
      to: params[:email],
      from: ENV['SMTP_SERVER_FROM'],
      subject: subject,
      body: body,
      via: :smtp,
      via_options: {
        address:        ENV['SMTP_SERVER_ADDRESS'],
        port:           ENV['SMTP_SERVER_PORT'],
        user_name:      ENV['SMTP_SERVER_USERNAME'],
        password:       ENV['SMTP_SERVER_PASSWORD'],
        authentication: 'plain',
        domain:         ENV['SMTP_SERVER_DOMAIN'],
        enable_starttls_auto: true
      }
    )
end
