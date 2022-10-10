class ShopperSlackNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(shopper)
    Slack::SlackNotification.new.send_fraud_notification(shopper)
  end
end
