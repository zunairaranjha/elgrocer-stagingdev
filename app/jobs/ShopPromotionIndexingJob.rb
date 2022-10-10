class ShopPromotionIndexingJob
  @queue = :product_indexing_queue

  def self.perform(*args)
    product_ids = ShopPromotion.where("start_time <= #{((Time.now + (Redis.current.get("promotion_index_hours") || SystemConfiguration.find_by(key: "promotion_index_hours").value).to_i.hours).utc.to_f * 1000).floor}")
                               .where("end_time > #{((Time.now - 1.day).utc.to_f * 1000).floor}")
                               .pluck(:product_id)
    Product.products_to_algolia(product_ids: product_ids)
  end
end

