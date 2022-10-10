class MonetizeShop < ActiveRecord::Migration
  def change
    add_monetize :shops, :price
  end
end
