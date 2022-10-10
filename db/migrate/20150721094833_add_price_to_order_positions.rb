class AddPriceToOrderPositions < ActiveRecord::Migration
  def up
    add_column :order_positions, :shop_price_cents, :integer, null: false, default: 0
    add_column :order_positions, :shop_price_currency, :string, null: false, default: "USD"
  end

  def down
    remove_column :order_positions, :shop_price_cents
    remove_column :order_positions, :shop_price_currency
  end
end
