class AddShopIdToShopperCartProducts < ActiveRecord::Migration
  def change
    add_column :shopper_cart_products, :shop_id, :integer
  end
end
