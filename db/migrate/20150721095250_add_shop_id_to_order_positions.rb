class AddShopIdToOrderPositions < ActiveRecord::Migration
  def up
    add_column :order_positions, :shop_id, :integer
  end
  def down
    remove_column :order_positions, :shop_id
  end
end
