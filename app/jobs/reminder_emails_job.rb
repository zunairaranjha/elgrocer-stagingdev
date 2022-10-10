require 'rubygems'
$LOGGER = Logger.new('log/resque_scheduler.log', 'daily')

class ReminderEmailsJob

  @queue = :reminder_emails_queue

  def self.perform
    $LOGGER.info "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    $LOGGER.info "[#{Time.now}] Start Reminder Emails Service."
    begin
      #fetch all the active emails rules in asce order
      email_rules = EmailRule.order_reminders.order("days_for asc")
      email_rules.each_with_index do |rule, index|
        next_rule = email_rules[index+1]
        run_at = DateTime.parse("#{Date.today} #{rule.send_time}")
        conditions = "created_at < '#{Date.today - rule.days_for.to_i.days}' "
        conditions += "and created_at >= '#{Date.today - next_rule.days_for.to_i.days}' " if next_rule.present?

        #fetch all shoppers registered during the two email rules days
        shoppers = Shopper.where("#{conditions}")

        #check if no order were placed and default address is present and order reminder email was already not sent
        shoppers = shoppers.select { |s| s.orders.blank? && s.default_address.present? && s.activity("#{rule.name}").blank? } if shoppers.present?

        #enque the shoppers on specific time to send the order reminder email for current email rule
        Resque.enqueue_at(run_at, SendReminderEmails, shoppers.map(&:id), rule.id) if shoppers.present?
      end if email_rules.present?

      $LOGGER.info "[#{Time.now}] End Reminder Emails Service."
    rescue => e
      $LOGGER.error "[#{Time.now}] Error processing Reminder Emails Service: #{e.inspect}"
      Airbrake.notify("[#{Time.now}] Error processing Reminder Emails Service: #{e.inspect}")
    end

  end

end