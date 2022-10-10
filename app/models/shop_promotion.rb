class ShopPromotion < ApplicationRecord
  belongs_to :product, optional: true, touch: true
  belongs_to :retailer, optional: true

  default_scope -> { where(is_active: true) }

  attr_accessor :time_of_start, :time_of_end

  validate :product_present
  validate :set_standard_price
  validate :date_range
  before_save :update_shop

  def time_of_start
    (Time.at(self.start_time / 1000)).strftime('%Y-%m-%d %H:%M:%S').to_s if self.start_time.present?
  end

  def time_of_end
    (Time.at(self.end_time / 1000)).strftime('%Y-%m-%d %H:%M:%S').to_s if self.end_time.present?
  end

  def set_standard_price
    errors.add(:standard_price, "Standard Price can't be less than price!") if standard_price.to_f > 0.0 && standard_price.to_f < price.to_f
    if standard_price.to_f.zero?
      price_data = Shop.select("MAX(price_dollars + price_cents/100.0) AS max_price, SUM(price_dollars + shops.price_cents/100.0) FILTER ( WHERE retailer_id = #{self.retailer_id} ) AS shop_price").where(product_id: product.id).limit(1)[0]
      std_price = price_data&.shop_price.to_f.round(2) > price.to_f ? price_data&.shop_price.to_f.round(2) : price_data&.max_price.to_f.round(2)
      self.standard_price = std_price > price.to_f ? std_price : price
    end
  end

  def product_present
    errors.add(:product_id, 'Product not found!') unless product
  end

  def product
    @product ||= Product.find_by(id: product_id)
  end

  def date_range
    errors.add(:time_of_end, 'End time should be greater than start time!') if time_of_end  <= time_of_start
  end

  def update_shop
    if self.is_active
      Shop.unscoped.where(product_id: self.product_id, retailer_id: self.retailer_id).update_all(is_promotional: self.is_active)
    else
      Shop.unscoped.where(product_id: self.product_id, retailer_id: self.retailer_id).update_all(is_promotional: self.is_active) unless
        ShopPromotion.where(product_id: self.product_id, retailer_id: self.retailer_id, is_active: true).count.positive?
    end
  end
end
