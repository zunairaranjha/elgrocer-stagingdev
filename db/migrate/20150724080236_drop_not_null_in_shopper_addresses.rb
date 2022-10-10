class DropNotNullInShopperAddresses < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE shopper_addresses ALTER COLUMN city DROP NOT NULL, ALTER COLUMN street DROP NOT NULL, ALTER COLUMN building_name DROP NOT NULL, ALTER COLUMN apartment_number DROP NOT NULL, ALTER COLUMN floor_number DROP NOT NULL'
  end

  def down
    execute 'ALTER TABLE shopper_addresses ALTER COLUMN city SET NOT NULL, ALTER COLUMN street SET NOT NULL, ALTER COLUMN building_name SET NOT NULL, ALTER COLUMN apartment_number SET NOT NULL, ALTER COLUMN floor_number SET NOT NULL'
  end
end
