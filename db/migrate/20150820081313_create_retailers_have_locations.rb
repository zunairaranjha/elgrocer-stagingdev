class CreateRetailersHaveLocations < ActiveRecord::Migration
  def up
    create_table :retailers_have_locations do |t|
      t.integer :retailer_id, index: true, null: false
      t.integer :location_id, index: true, null: false
      t.timestamps
    end
  end

  def down
    drop_talbe :retailers_have_locations
  end
end
