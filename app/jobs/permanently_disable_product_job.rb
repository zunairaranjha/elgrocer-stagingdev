require 'csv'

class PermanentlyDisableProductJob
  @queue = :disabled_products_queue

  def self.perform
    csv_headers = %w[barcode price retailer_id price_currency is_promotional promotion_only is_published is_available enable_product]

    shops = Shop.unscoped.joins('JOIN products ON products.id = shops.product_id').where("detail->>'permanently_disabled' <> '0'").select('shops.retailer_id, round(shops.price_dollars::numeric + shops.price_cents::numeric / 100.0, 2) AS full_price, shops.is_published, shops.is_available, shops.is_promotional, shops.promotion_only, shops.detail, shops.price_currency, products.barcode').order('shops.retailer_id')
    RetailerMailer.permanently_disabled_products(SystemConfiguration.find_by_key('emails_of_catalog')&.value, CSV.generate do |csv|
      csv << csv_headers
      shops.each do |shop|
        csv << [shop.barcode, shop.full_price, shop.retailer_id, shop.price_currency, shop.is_promotional, shop.promotion_only, shop.is_published, shop.is_available, shop.detail['permanently_disabled'].to_i.positive?]
      end
    end).deliver_later
  end

end
