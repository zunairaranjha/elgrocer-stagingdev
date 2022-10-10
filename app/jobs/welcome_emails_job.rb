require 'rubygems'
$LOGGER = Logger.new('log/resque_scheduler.log', 'daily')

class WelcomeEmailsJob

  @queue = :welcome_emails_queue

  def self.perform(args)
    $LOGGER.info "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    $LOGGER.info "[#{Time.now}] Start Welcome Emails Service."
    begin
      #fetch all shoppers registered in the last given time interval
      shoppers = Shopper.where("created_at >= ?", Time.now - args[:interval].to_i.hours)

      #check if default address is present and welcome email was already not sent
      shoppers.each do |shopper|
        if shopper.activity("Welcome Email").blank?
          if shopper.default_address.present?
            #send welcome emails to new shoppers along with open shops in the live area
            shopper.default_address.send_welcome_email_to_user
          else #if shopper.non_live_address.present?
            #send welcome emails to new shoppers along without shops
            shopper.send_welcome_email_to_user
          end
        end
      end if shoppers.present?
      $LOGGER.info "[#{Time.now}] End Welcome Emails Service."
    rescue => e
      $LOGGER.error "[#{Time.now}] Error processing Welcome Emails Service: #{e.inspect}"
      Airbrake.notify("[#{Time.now}] Error processing Welcome Emails Service: #{e.inspect}")
    end
  end

end