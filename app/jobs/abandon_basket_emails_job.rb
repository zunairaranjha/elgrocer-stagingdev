require 'rubygems'
$LOGGER = Logger.new('log/resque_scheduler.log', 'daily')

class AbandonBasketEmailsJob

  @queue = :abandon_basket_emails_queue

  def self.perform
    $LOGGER.info "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    $LOGGER.info "[#{Time.now}] Start Abandon Basket Emails Service."
    begin
      #fetch all the active emails rules in asce order
      email_rules = EmailRule.abandon_baskets.order("days_for asc")
      email_rules.each_with_index do |rule, index|
        next_rule = email_rules[index+1]
        run_at = DateTime.parse("#{Date.today} #{rule.send_time}")

        conditions = "created_at < '#{Date.today - rule.days_for.to_i.days}' "
        conditions += "and created_at >= '#{Date.today - next_rule.days_for.to_i.days}' " if next_rule.present?

        #fetch all shopper carts created during the two email rules days
        shopper_carts = ShopperCart.where("#{conditions}")

        #check if abandon basket email was already not sent
        shopper_carts = shopper_carts.select { |sc| sc.shopper.activity("#{rule.name}").blank? } if shopper_carts.present?

        #enque the shoppers on specific time to send the abandon basket email for current email rule
        Resque.enqueue_at(run_at, SendAbandonBasketEmails, shopper_carts.map(&:shopper_id), rule.id) if shopper_carts.present?
      end if email_rules.present?

      $LOGGER.info "[#{Time.now}] End Abandon Basket Emails Service."
    rescue => e
      $LOGGER.error "[#{Time.now}] Error processing Abandon Basket Emails Service: #{e.inspect}"
      Airbrake.notify("[#{Time.now}] Error processing Abandon Basket Emails Service: #{e.inspect}")
    end

  end

end