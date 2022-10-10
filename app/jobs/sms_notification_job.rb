class SmsNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(to, message)
    Sms::SmsNotification.new.send_sms(to, message)
  end

end
