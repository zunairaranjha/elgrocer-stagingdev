require 'rubygems'
# $LOGGER = Logger.new('log/resque_scheduler.log', 'daily')

class ManageShopProducts
  @queue = :default
  def self.perform(rule_id, category_ids, retailer_ids = [])
    # $LOGGER.info "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    # $LOGGER.info "[#{Time.now}] Start Applying Schedule Rules"
    # begin
      # products = Shop.where(category_id: category_ids, is_available: false)
      products = retailer_ids.any? ? Shop.unscoped.joins(:subcategories).where(categories: {id: category_ids}, is_available: false, retailer_id: retailer_ids) : Shop.unscoped.joins(:subcategories).where(categories: {id: category_ids}, is_available: false)
      #products.update_all(is_available: true)

      products.find_each do |s|
        s.owner_for_log = ShopProductRule.find(rule_id) rescue s
        s.update_attributes({is_available: true}) rescue s
      end
      # $LOGGER.info "[#{Time.now}] End Schedule Rule"
    # rescue => e
    #   $LOGGER.error "[#{Time.now}] Error processing Products: #{e.inspect}"
    #   Airbrake.notify("[#{Time.now}] Error processing Products: #{e.inspect}")
    # end

  end

end
