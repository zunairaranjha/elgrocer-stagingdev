require 'rubygems'
$LOGGER = Logger.new('log/resque_scheduler.log', 'daily')

class SendReminderEmails

  @queue = :send_reminder_emails_queue

  def self.perform(shoppers_ids, rule_id)
    $LOGGER.info "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    $LOGGER.info "[#{Time.now}] Start Sending Reminder Emails."
    begin
      shoppers_ids.each { |shopper_id| ShopperMailer.order_reminder(shopper_id, rule_id).deliver_later }
      $LOGGER.info "[#{Time.now}] End Sending Reminder Emails."
    rescue => e
      $LOGGER.error "[#{Time.now}] Error processing Sending Reminder Emails: #{e.inspect}"
      Airbrake.notify("[#{Time.now}] Error processing Sending Reminder Emails: #{e.inspect}")
    end

  end

end