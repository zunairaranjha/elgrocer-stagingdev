class ShopperCartProducts::Base < ActiveInteraction::Base

  private

  def shopper_exists
    errors.add(:shopper_id, 'Shopper does not exist') unless Shopper.exists?(id: shopper_id)
  end

  def retailer_exists
    errors.add(:retailer_id, 'Retailer does not exist') unless Retailer.exists?(id: retailer_id)
  end

  def product_exists
    errors.add(:product_id, 'Product does not exist') unless Product.unscoped.find(product_id)
  end

  def shop_exists
    errors.add(:shop, 'shop do not exist') unless Shop.unscoped.exists?({retailer_id: retailer_id, product_id: product_id})
  end

end
