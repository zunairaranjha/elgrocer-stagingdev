class CreateRetailerDeliveryZones < ActiveRecord::Migration
  def change
    create_table :retailer_delivery_zones do |t|
      t.references :retailer, index: true
      t.references :delivery_zone, index: true

      t.timestamps null: false
    end
    add_foreign_key :retailer_delivery_zones, :retailers
    add_foreign_key :retailer_delivery_zones, :delivery_zones
  end
end
