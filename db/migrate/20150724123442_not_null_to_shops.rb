class NotNullToShops < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE shops ALTER COLUMN price_dollars SET NOT NULL'
    execute 'ALTER TABLE shops ALTER COLUMN price_dollars SET DEFAULT 0'

  end
  def down
    execute 'ALTER TABLE shops ALTER COLUMN price_dollars DROP NOT NULL DEFAULT'
  end
end
