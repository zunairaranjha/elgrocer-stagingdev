class ChangeDefaultValueForShops < ActiveRecord::Migration
  def up
    execute "ALTER TABLE shops ALTER COLUMN price_currency SET DEFAULT 'AED'"
    execute "ALTER TABLE order_positions ALTER COLUMN shop_price_currency SET DEFAULT 'AED'"
  end
  def down
    execute "ALTER TABLE shops ALTER COLUMN price_currency SET DEFAULT 'USD'"
    execute "ALTER TABLE order_positions ALTER COLUMN shop_price_currency SET DEFAULT 'USD'"
  end
end
