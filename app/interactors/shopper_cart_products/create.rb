# frozen_string_literal: true

class ShopperCartProducts::Create < ShopperCartProducts::Base

  integer :shopper_id
  integer :retailer_id
  integer :product_id
  integer :quantity
  string :date_time_offset, default: nil

  validate :shopper_exists
  validate :retailer_exists
  validate :product_exists

  def execute
    if shopper_cart_product.present?
      update_shopper_cart_product
    elsif quantity.positive?
      create_shopper_cart_product
    end
  end

  private

  def create_shopper_cart_product
    ShopperCartProduct.create!({
                                 retailer_id: retailer_id,
                                 shopper_id: shopper_id,
                                 product_id: product_id,
                                 quantity: quantity,
                                 shop_id: shop&.id,
                                 date_time_offset: date_time_offset
                               })
  end

  def shopper_cart_product
    @shopper_cart_product ||= ShopperCartProduct.find_by({ retailer_id: retailer_id, shopper_id: shopper_id,
                                                           product_id: product_id })
  end

  def update_shopper_cart_product
    if quantity.positive?
      shopper_cart_product.update!({ quantity: quantity, date_time_offset: date_time_offset })
      shopper_cart_product
    else
      shopper_cart_product.destroy
    end
  end

  def shop
    Shop.unscoped.select(:id).find_by(retailer_id: retailer_id, product_id: product_id)
  end

end
