class TwilioTextMessenger
  attr_reader :message, :to

  def initialize(message, to)
    @message = message
    @to = to
  end

  def call
    client = Twilio::REST::Client.new
    client.messages.create({
      from: Rails.application.secrets.twilio_phone_number,
      to: to,
      body: message
    })
  end
end