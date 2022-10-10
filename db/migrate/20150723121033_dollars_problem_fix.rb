class DollarsProblemFix < ActiveRecord::Migration
  def up
    add_column :order_positions, :shop_price_dollars, :integer, null: false, default: 0
  end

  def down
    down_column :order_positions, :shop_price_dollars
  end
end
