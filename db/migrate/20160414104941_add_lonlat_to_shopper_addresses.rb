class AddLonlatToShopperAddresses < ActiveRecord::Migration
  def change
    add_column :shopper_addresses, :lonlat, :st_point, geographic: true

    add_index :shopper_addresses, :lonlat, using: :gist
  end
end
