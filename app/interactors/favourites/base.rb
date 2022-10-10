class Favourites::Base < ActiveInteraction::Base

  private

  def product_exists
    errors.add(:product_id, 'Product does not exist') unless product.present?
  end

  def retailer_exists
    errors.add(:retailer_id, 'Retailer does not exist') unless retailer.present?
  end

  def retailer_is_not_favourite
    errors.add(:retailer_id, 'Retailer is already in your favourites!') unless ShopperFavouriteRetailer.find_by(shopper_id: shopper_id, retailer_id: retailer_id).nil?
  end

  def product_is_not_favourite
    errors.add(:product_id, 'Product is already in your favourites!') unless ShopperFavouriteProduct.find_by(shopper_id: shopper_id, product_id: product_id).nil?
  end


end
