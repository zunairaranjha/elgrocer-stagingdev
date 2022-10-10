class RetailerSlackNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(retailer_id, source)
    Slack::SlackNotification.new.send_retailer_status_change_notification(retailer_id, source)
  end

end
