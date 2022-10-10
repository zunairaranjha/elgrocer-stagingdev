class Sms::SmsNotification
  # Initialize the object with a slack webhook uri
  def initialize
    @user = ENV['SMSGLOBAL_USER']
    @pass = ENV['SMSGLOBAL_PASS']
    @base_url = ENV['SMSDLOBAL_URL']
    @client = HTTPClient.new
    # @nexmo = Nexmo::Client.new(key: ENV['NEXMO_API_KEY'],secret: ENV['NEXMO_API_SECRET'])
  end

  def send_sms(to , message)
    body = {
        'action' => 'sendsms',
        'user' => @user,
        'password' => @pass,
        'from'=> 'elGrocer',
        'to' => to.gsub("+",''),
        'text' => message
    }
    @client.post @base_url, body
    # @nexmo.sms.send(from: 'El Grocer', to: to , text: message)
  end

end
