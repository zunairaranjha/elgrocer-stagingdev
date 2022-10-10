class AddPriceToShopProductLogs < ActiveRecord::Migration
  def change
    add_column :shop_product_logs, :price, :float
  end
end
