class AddMinBasketValueToPromoCode < ActiveRecord::Migration
  def change
    add_column :promotion_codes, :min_basket_value, :decimal, default: 0
  end
end
