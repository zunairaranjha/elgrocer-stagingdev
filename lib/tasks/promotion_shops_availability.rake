namespace :promotion_shops do
  desc 'This job will unavailable the shops after checking if promotion is going to be expire and there is no standard price > promotional price'
  task availability: :environment do
    # shops = Shop.joins("JOIN shop_promotions ON shop_promotions.retailer_id = shops.retailer_id AND shop_promotions.product_id = shops.product_id AND (shops.price_dollars + shops.price_cents/100.0) = shop_promotions.price AND
    #               shop_promotions.is_active = 't' AND shop_promotions.price = shop_promotions.standard_price AND shop_promotions.end_time <= #{(Time.now.end_of_day.utc.to_f * 1000).floor}")
    # product_ids = shops.distinct.pluck(:product_id)
    # shops.update_all("is_available = 'f', updated_at = '#{Time.now}', detail = detail::jsonb || '{\"owner_type\": \"Promotion Disabling Scheduler\",\"owner_id\": \"-1\"}'::jsonb")
    shop_promotions = ShopPromotion.where("shop_promotions.end_time <= #{(Time.now.end_of_day.utc.to_f * 1000).floor}")
    product_ids = shop_promotions.distinct.pluck(:product_id) #| product_ids
    shop_promotions.update_all("is_active = 'f', updated_at = '#{Time.now}'")
    unless product_ids.blank?
      product_ids.each_slice(1000) do |pro_ids|
        AlgoliaProductIndexingJob.perform_later(pro_ids)
      end
    end
  end
end
