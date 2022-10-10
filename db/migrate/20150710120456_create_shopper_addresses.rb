class CreateShopperAddresses < ActiveRecord::Migration
  def up
    create_table :shopper_addresses do |t|
        t.belongs_to :shopper, index: true
        t.string :address_name, :null => false
        t.string :city, :null => false
        t.string :area, :null => false
        t.string :street, :null => false
        t.string :building_name, :null => false
        t.integer :apartment_number, :null => false
        t.integer :floor_number, :null => false
        t.datetime :created_at
    end
    execute "ALTER TABLE shopper_addresses ALTER COLUMN created_at SET DEFAULT now()"
  end

  def down
    drop_table :shopper_addresses
  end
end
