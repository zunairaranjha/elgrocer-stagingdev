class CreatePickupLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :pickup_locations do |t|
      t.integer :retailer_id
      t.string :details
      t.string :details_ar
      t.boolean :is_active, :default => true
      t.st_point :lonlat , geographic: true
      t.attachment :photo

      t.timestamps null: false
    end

      add_index :pickup_locations, :lonlat, using: :gist

  end
end
