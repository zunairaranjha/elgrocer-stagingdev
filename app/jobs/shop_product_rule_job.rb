require 'rubygems'
$LOGGER = Logger.new('log/resque_scheduler.log', 'daily')

class ShopProductRuleJob

  @queue = :default

  def self.perform
    $LOGGER.info "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    $LOGGER.info "[#{Time.now}] Start Schedule Rules Service."
    begin
      schedule_rules = ShopProductRule.where(is_enable: true).order("at_day asc")
      schedule_rules.each_with_index do |rule, index|
        #next_rule = schedule_rules[index+1]
        run_at = DateTime.parse("#{Date.today} #{rule.at_time} +4")
        Resque.enqueue_at(run_at, ManageShopProducts, rule.id, rule.category_ids, rule.retailer_ids ) if rule.category_ids.present?
      end if schedule_rules.present?

      $LOGGER.info "[#{Time.now}] End Schedule Rules Service."
    rescue => e
      $LOGGER.error "[#{Time.now}] Error processing Schedule Rules  Service: #{e.inspect}"
      Airbrake.notify("[#{Time.now}] Error processing Schedule Rules Service: #{e.inspect}")
    end

  end

end
