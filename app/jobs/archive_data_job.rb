class ArchiveDataJob
  @queue = :archive_data_queue

  def self.perform
    shop_promotions = ShopPromotion.where("end_time < #{((Time.now - 2.week).utc.to_f * 1000).floor}")
    if shop_promotions.present?
      archive_shops = Array.new
      time = Time.now
      shop_promotions.each { |shop_promotion| archive_shops << DataArchive.new( owner: shop_promotion, detail: shop_promotion.attributes.to_json, created_at: time) }
      query = (DataArchive.import data).ids rescue ''
      shop_promotions.delete_all unless query.blank?
    end
  end

end

