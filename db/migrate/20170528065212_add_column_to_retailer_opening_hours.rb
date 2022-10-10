class AddColumnToRetailerOpeningHours < ActiveRecord::Migration
  def change
    add_column :retailer_opening_hours, :retailer_delivery_zone_id, :integer
    # add_reference :retailer_opening_hours, :retailer_delivery_zones, index: true
    # add_foreign_key :retailer_opening_hours, :retailer_delivery_zones
  end
end
