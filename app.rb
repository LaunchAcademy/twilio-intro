require 'dotenv'
require 'sinatra'
require 'twilio-ruby'

Dotenv.load

configure do
  set :twilio_phone_number, ENV['TWILIO_PHONE_NUMBER']

  Twilio.configure do |config|
    config.account_sid = ENV['TWILIO_ACCOUNT_SID']
    config.auth_token = ENV['TWILIO_AUTH_TOKEN']
  end
end

get '/' do
  client = Twilio::REST::Client.new
  @messages = client.messages.list(to: settings.twilio_phone_number)

  erb :index
end

get '/conversations/:sender_number' do
  client = Twilio::REST::Client.new
  @sender_number = params[:sender_number]

  incoming = client.messages.list(
    from: @sender_number,
    to: settings.twilio_phone_number
  )

  outgoing = client.messages.list(
    from: settings.twilio_phone_number,
    to: @sender_number
  )

  @messages = (incoming + outgoing).sort_by do |message|
    message.date_sent
  end

  erb :'conversations/show'
end
