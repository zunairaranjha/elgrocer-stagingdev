class Orders::CheckOrderPositions < Orders::Base
  float :longitude
  float :latitude
  array :products

  # This will return all product that are NOT in retailer's shop.
  validate :location_exists

  def execute
    check_retailers
  end

  private

  def shopper_service
    @shopper_service ||= DeliveryZone::ShopperService.new(longitude, latitude)
  end

  def retailers
    @retailers ||= shopper_service.retailers_active_all.select('retailers.*, max(retailer_delivery_zones.min_basket_value) min_basket_value, max(retailer_delivery_zones.id) retailer_delivery_zones_id').group('retailers.id')
  end

  def check_order_position(product_id, retailer)
    retailer.shops.find_by(product_id: product_id)
  end

  def check_order_positions(retailer)
    unavailable_products_result = []
    available_products_result = []
    products.each do |product_id|
      shop_result = check_order_position(product_id, retailer)
      if shop_result
        available_products_result.push(shop_result.product)
      else
        unavailable_products_result.push(product_id.to_i)
      end
    end
    result = {unavailable_products: unavailable_products_result, available_products: available_products_result}
    result
  end

  def check_retailers
    result = []
    retailers.find_each do |retailer|
      positions = check_order_positions(retailer)
      result.push(
        { retailer: retailer,
          unavailable_products: positions[:unavailable_products],
          available_products: positions[:available_products] }
      )
    end
    result
  end

  def location_exists
    unless shopper_service.is_covered?
      errors.add(:location, "Location is not covered")
    end
  end
end
