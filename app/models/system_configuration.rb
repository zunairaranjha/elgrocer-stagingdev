class SystemConfiguration < ActiveRecord::Base
  after_save :cache_update

  enum order_tracking: { job_interval: 0, not_accepted: 1, not_enrouted: 2, not_ready_to_deliver: 3 } # , _prefix: "order_tracking"

  def cache_update
    if %w[promotion_index_hours uc_promotion_days complete_order_show_time storyly_instance sale_tag_url en_route_to_deliver_time applepay_switch fetch_catalog_from_algolia orders_topic trn_number locus:send-on-status-id wallet_topic locus_webhook_urls].include? self.key
      Redis.current.set self.key, self.value
    end
  end

  def self.get_key_value(key)
    value = Redis.current.get(key)
    return value if value.present?

    value ||= SystemConfiguration.find_by(key: key)&.value
    Redis.current.set key, value
    value
  end
end
