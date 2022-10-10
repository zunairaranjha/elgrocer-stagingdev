require 'rubygems'
$LOGGER = Logger.new('log/resque_scheduler.log', 'daily')

class SendAbandonBasketEmails

  @queue = :send_abandon_basket_emails_queue

  def self.perform(shoppers_ids, rule_id)
    $LOGGER.info "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    $LOGGER.info "[#{Time.now}] Start Sending Abandon Basket Emails."
    begin
      shoppers_ids.each { |shopper_id| ShopperMailer.abandon_basket(shopper_id, rule_id).deliver_later }
      $LOGGER.info "[#{Time.now}] End Sending Abandon Basket Emails."
    rescue => e
      $LOGGER.error "[#{Time.now}] Error processing Sending Abandon Basket Emails: #{e.inspect}"
      Airbrake.notify("[#{Time.now}] Error processing Sending Abandon Basket Emails: #{e.inspect}")
    end

  end

end