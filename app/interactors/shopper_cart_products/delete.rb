class ShopperCartProducts::Delete < ShopperCartProducts::Base

  integer :shopper_id
  integer :retailer_id

  # validate :shopper_exists
  # validate :shopper_cart_exists
  # validate :shopper_cart_product_exists

  def execute
    delete_shopper_cart_products
  end

  private

  def delete_shopper_cart_products
    ShopperCartProduct.where({retailer_id: retailer_id, shopper_id: shopper_id}).delete_all
  end

end
